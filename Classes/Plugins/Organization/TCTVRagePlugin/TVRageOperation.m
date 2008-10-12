//
//  TVRageOperation.m
//  Technicolor
//
//  Created by Steve Streza on 9/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TVRageOperation.h"

@implementation TVRageOperation

-(id)initWithOperation:(TCTVRageOperationType)opType dataObject:(id)obj delegate:(id)del{
	if(self = [super init]){
		operationType = opType;
		dataObject = [obj retain];
		delegate = del;
		
		webView = [[WebView alloc] initWithFrame:NSMakeRect(0,0,320,240)];
	}
	return self;
}

-(void)dealloc{
	[dataObject release];
	[super dealloc];
}

-(void)main{
//	NSLog(@"Beginning operation");
	switch(operationType){
		case TCTVRageGetShowsOperation:
			if(dataObject == nil){
				[self loadAllShows];
			}
			break;
		case TCTVRageGetEpisodesOperation:
			if([dataObject isKindOfClass:[TCTVShow class]]){
				[self loadEpisodesForShow:(TCTVShow *)dataObject];
			}
			break;
		case TCTVRageGetEpisodeInfoOperation:
			if([dataObject isKindOfClass:[TCTVEpisode class]]){
				[self loadInfoForEpisode:(TCTVEpisode *)dataObject];
			}
			break;
		case TCTVRageGetCurrentDayScheduleOperation:
			[self loadCurrentDaySchedule];
	}
}

-(void)loadCurrentDaySchedule{
//	NSURL *url = [NSURL URLWithString:kTVRageQuickInfoScheduleString];
//	NSData *data = [TCDownload loadResourceDataForURL:url];
//	NSString *urlContents = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
//	NSLog(@"Loading current");
	NSString *urlContents = [TCDownload loadResourceStringForURL:[NSURL URLWithString:kTVRageQuickInfoScheduleString] encoding:NSUTF8StringEncoding];
	
	NSString *dateString = nil;
	NSCalendarDate *currentTime = nil;
	
	NSArray *lines = [urlContents componentsSeparatedByString:@"\n"];
	for(NSString *line in lines){
		NSString *key = nil;
		NSString *value = nil;
		
		[self parseLine:line forKey:&key value:&value];
		
		if(key && value){
			if([key isEqualToString:@"day"]){
				dateString = value;
			}else if([key isEqualToString:@"time"]){
				[currentTime release];
				NSString *timeString = [NSString stringWithFormat:@"%@ %@",dateString,value];
				currentTime = [[NSCalendarDate dateWithString:timeString
											  calendarFormat:@"%A, %d %b %Y %I:%M %p"] retain];
//				NSLog(@"Got time %@ from str %@",[currentTime descriptionWithCalendarFormat:@"%b. %d, %I:%M %p"],timeString);
			}else if([key isEqualToString:@"show"]){
//				NSLog(@"Parsing show %@",value);
				NSArray *components = [value componentsSeparatedByString:@"^"];
				NSString *episodeID = [components objectAtIndex:2];
				
				NSUInteger season  = NSNotFound;
				NSUInteger episode = NSNotFound;
				
				[self parseEpisodeID:episodeID withSeason:&season episode:&episode];
				if(season != NSNotFound && episode != NSNotFound){
					NSString *network   = [components objectAtIndex:0];
					NSString *showName  = [components objectAtIndex:1];
					NSURL *metadataURL  = [NSURL URLWithString:[components objectAtIndex:3]];
					TCTVShow *show = [TCTVShow showWithName:showName];
					TCTVEpisode *showEpisode = [TCTVEpisode showVideoWithEpisodeName:nil season:season episodeNumber:episode show:show];
					[showEpisode setValue:[currentTime copy] forKey:@"airDate"];

					if(![showEpisode episodeName]){
//						NSLog(@"Adding operation for %@ - %@",[[showEpisode show] showName], [showEpisode episodeID]);
						[[TVRageController sharedController] beginLoadOperation:TCTVRageGetEpisodeInfoOperation withInfoObject:showEpisode delegate:nil];
					}

//					NSLog(@"Episode %i x %i of %@ airs at %@",season,episode,showName,[currentTime descriptionWithCalendarFormat:@"%b. %d, %I:%M %p"]);
				}
			}
		}
	}
}

-(void)parseEpisodeID:(NSString *)episodeID withSeason:(NSUInteger *)seasonPtr episode:(NSUInteger *)episodePtr{
	NSArray *components = [episodeID componentsSeparatedByString:@"x"];
	if([components count] == 2){
		*seasonPtr = [[components objectAtIndex:0] intValue];
		*episodePtr = [[components objectAtIndex:1] intValue];
	}
}

-(void)parseLine:(NSString *)line forKey:(NSString **)keyPtr value:(NSString **)valuePtr{
	@try {
		if([line length] > 0 && [[line substringToIndex:1] isEqualToString:@"["]){
			NSUInteger closeIndex = [line rangeOfString:@"]"].location;
			if(closeIndex != NSNotFound){
				NSString *key = [[line substringWithRange:NSMakeRange(1,closeIndex-1)] lowercaseString];
				
				NSRange valueRange = NSMakeRange(0,0);
				valueRange.location = closeIndex+1;
				valueRange.length = line.length - valueRange.location - key.length - 3;
				
				NSString *value = [line substringWithRange:valueRange];
				*keyPtr = key;
				*valuePtr = value;
			}
		}	
	}
	@catch (NSException * e) {
		NSLog(@"Exception: %@",e);
		*keyPtr = nil;
		*valuePtr = nil;
	}
}

-(void)loadAllShows{
	
}

-(void)loadEpisodesForShow:(TCTVShow *)show{
//	NSLog(@"Loading episodes for show %@",[show showName]);
	NSDictionary *dictionary = [self quickInfoForURL:[TVRageOperation quickInfoURLForShow:show]];
}

-(void)loadInfoForEpisode:(TCTVEpisode *)episode{
//	NSLog(@"Loading info for %@ - %@",[[episode show] showName], [episode episodeID]);
	
	NSURL *url = [TVRageOperation quickInfoURLForEpisode:episode];
	NSDictionary *dictionary = [self quickInfoForURL:url];
	
	[episode setValue:[self episodeNameFromQuickInfo:dictionary] forKey:@"episodeName"];
	[episode setValue:[self networkNameFromQuickInfo:dictionary] forKey:@"network"];
	
//	NSLog(@"Got %@ - %@: %@ - %@",[[episode show] showName], [episode episodeID],[episode episodeName], [episode network]);
//	NSLog(@"%@ - %ix%i - %@",[[episode show] showName], [[episode seasonNumber] intValue], [[episode episodeNumber] intValue], [episode episodeName]);
}

-(NSString *)networkNameFromQuickInfo:(NSDictionary *)dict{
	return (NSString *)[dict objectForKey:@"Network"];
}

-(NSString *)episodeNameFromQuickInfo:(NSDictionary *)dict{
	NSString *value = [dict objectForKey:@"Episode Info"];
	NSArray *components = [value componentsSeparatedByString:@"^"];
	if([components count] == 3){
//		NSLog(@"Episode name: %@",[components objectAtIndex:1]);
		return [components objectAtIndex:1];
//	}else{
//		NSLog(@"Couldn't process: %@",dict);
	}
	return nil;
}

+(NSURL *)quickInfoURLForShow:(TCTVShow *)show{
	NSString *urlString = [NSString stringWithFormat:@"%@?%@=%@",kTVRageQuickInfoBaseURLString, kTVRageQuickInfoShowNameURLKey, [show showName]];
	return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
}

+(NSURL *)quickInfoURLForEpisode:(TCTVEpisode *)episode{
	NSURL *showURL = [self quickInfoURLForShow:[episode show]];
	NSString *urlString = [NSString stringWithFormat:@"%@&%@=%ix%i",showURL, kTVRageQuickInfoEpisodeURLKey, [[episode seasonNumber] intValue], [[episode episodeNumber] intValue]];
	return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
}

-(NSDictionary *)quickInfoForURL:(NSURL *)url{
//	NSData *data = [url resourceDataUsingCache:NO];
	NSString *contents = [TCDownload loadResourceStringForURL:url encoding:NSASCIIStringEncoding];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	NSArray *lines = [contents componentsSeparatedByString:@"\n"];
	for(NSString *line in lines){
		if([line length] > 0){
			NSArray *lineParts = [line componentsSeparatedByString:@"@"];
			
			if([lineParts count] == 2){
				NSString *key   = [lineParts objectAtIndex:0];
				NSString *value = [lineParts objectAtIndex:1];
				
				[dict setObject:value forKey:key];
			}
		}
	}
	return dict;
	
	return nil;
}

@end
