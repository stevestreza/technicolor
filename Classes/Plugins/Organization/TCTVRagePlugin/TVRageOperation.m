/*
 
 Copyright (c) 2008 Technicolor Project
 Licensed under the MIT License
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "TVRageOperation.h"

#import "TCTVEpisode.h"
#import "TCDataStore.h"

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
				[self loadShowInformation:(TCTVShow *)dataObject];
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
	NSLog(@"Loading episodes for show %@",[show showName]);
	
	NSString *showID = [self showIDForShow:show];
	NSLog(@"%@ has show ID %@",[show showName], showID);
	
	NSXMLDocument *doc = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:kTVRageXMLEpisodeListURLString(showID)]
															  options:0
																error:nil];
	
	NSUInteger seasonCount = 0;
	
	NSArray *seasons = [[[[doc rootElement] elementsForName:@"Episodelist"] objectAtIndex:0] elementsForName:@"Season"];
	for(NSXMLElement *seasonElement in seasons){
		NSUInteger seasonNumber = [[[seasonElement attributeForName:@"no"] stringValue] intValue];
		NSArray *episodes = [seasonElement elementsForName:@"episode"];
		for(NSXMLElement *episodeElement in episodes){
			NSUInteger episodeNumber = [[[[episodeElement elementsForName:@"epnum"] objectAtIndex:0] stringValue] intValue] - seasonCount;
			NSString *title = [[[episodeElement elementsForName:@"title"] objectAtIndex:0] stringValue];
			
//			TCTVEpisode *episode = [TCTVEpisode showVideoWithEpisodeName:title season:seasonNumber episodeNumber:episodeNumber show:show];
			TCDataStore *dataStore = (TCDataStore *)[[NSApp delegate] dataStore];
			TCTVEpisode *episode = [dataStore objectForClass:[TCTVEpisode class] 
									withValues:[NSDictionary dictionaryWithObjectsAndKeys:
												title,@"episodeName",
												[NSNumber numberWithUnsignedInteger:seasonNumber], @"seasonNumber",
												[NSNumber numberWithUnsignedInteger:episodeNumber], @"episodeNumber",
												nil]
									createIfNeeded:YES];
			
			NSCalendarDate *airDate = [NSCalendarDate dateWithString:[[[episodeElement elementsForName:@"airdate"] objectAtIndex:0] stringValue]
													  calendarFormat:@"%Y-%m-%d"];
			[episode setValue:airDate forKey:@"airDate"];
		}
		seasonCount += episodes.count;
	}
}

-(void)loadShowInformation:(TCTVShow *)show{
	NSDictionary *dictionary = [self quickInfoForURL:[TVRageOperation quickInfoURLForShow:show]];
	
	if([dictionary valueForKey:@"Show URL"]){
		NSURL *showURL = [NSURL URLWithString:[dictionary valueForKey:@"Show URL"]];
		NSLog(@"Setting show url %@",showURL);
		[show setValue:showURL forUndefinedKey:@"TVRageShowURL"];
		NSLog(@"Show URL? %@",[show valueForKey:@"TVRageShowURL"]);
	}
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
	return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

-(NSDictionary *)quickInfoForURL:(NSURL *)url{
//	NSData *data = [url resourceDataUsingCache:NO];
	NSString *contents = [TCDownload loadResourceStringForURL:url encoding:NSUTF8StringEncoding];
	
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

-(NSString *)showIDForShow:(TCTVShow *)show{
	if([show valueForKey:@"TVRageShowID"]){
		return [show valueForKey:@"TVRageShowID"];
	}
	
	NSString *showName = [show showName];
	
	NSString *urlString = kTVRageXMLSearchURLString(showName);
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSData *data = [TCDownload loadResourceDataForURL:url];
	
	NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data options:0 error:nil];
	NSArray *shows = [[doc rootElement] elementsForName:@"show"];
	
	NSString *showID = nil;
	
	for(NSXMLElement *showElement in shows){
		if([[[[showElement elementsForName:@"name"] objectAtIndex:0] stringValue] isEqualToString:showName]){
			showID = [[[showElement elementsForName:@"showid"] objectAtIndex:0] stringValue];
			break;
		}
	}
	
	if(showID){
		[show setValue:showID forUndefinedKey:@"TVRageShowID"];
	}
	return showID;
}
  
@end
