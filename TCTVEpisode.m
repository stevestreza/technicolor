//
//  TCTVEpisode.m
//  Technicolor
//
//  Created by Steve Streza on 8/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCTVEpisode.h"
#import "TCTVShow.h"

@implementation TCTVEpisode

+(TCTVEpisode *)showVideoWithEpisodeName:(NSString *)name season:(int)season episodeNumber:(int)episode show:(TCTVShow *)show{
	if([[show valueForKey:@"numberOfSeasons"] intValue] < season){
		[show setValue:[NSNumber numberWithInt:season] forKey:@"numberOfSeasons"];
	}	
	
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"TVEpisode" inManagedObjectContext:moc];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	// Set example predicate and sort orderings...
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"((show.showName == %@) AND (seasonNumber == %i) AND (episodeNumber == %i))", [show showName], season, episode];
	[request setPredicate:predicate];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"season" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	if (array == nil || array.count == 0)
	{
//		NSLog(@"Creating episode on %@ thread",([NSThread isMainThread] ? @"main" : @"NOT MAIN"));
		TCTVEpisode *newVideo = [NSEntityDescription insertNewObjectForEntityForName:@"TVEpisode"
														  inManagedObjectContext:moc];
		[newVideo setValue:name forKey:@"episodeName"];
		[newVideo setValue:[NSNumber numberWithInt:season] forKey:@"seasonNumber"];
		[newVideo setValue:[NSNumber numberWithInt:episode] forKey:@"episodeNumber"];
		@try {
			[newVideo setValue:show forKey:@"show"];
		}
		@catch (NSException * e) {
			NSLog(@"Wtf? %@",e);
		}
		
		return newVideo;
	}
	else{
		TCTVEpisode *video = [array objectAtIndex:0];
		return video;
	}
}

+(void)getStartOfToday:(NSDate **)startPtr endOfToday:(NSDate **)endPtr{
	NSCalendarDate *now = [NSCalendarDate calendarDate];
	
	NSInteger month = [now monthOfYear];
	NSInteger day   = [now dayOfMonth];
	NSInteger year  = [now yearOfCommonEra];
	
	NSCalendarDate *startOfToday = [NSCalendarDate dateWithYear:year
														  month:month 
															day:day 
														   hour:0 
														 minute:0 
														 second:0
													   timeZone:[NSTimeZone localTimeZone]];
	NSDate *endOfToday = [startOfToday dateByAddingYears:0 
												  months:0 
													days:0 
												   hours:24 
												 minutes:0
												 seconds:0];
	
	*startPtr = startOfToday;
	*endPtr = endOfToday;
}

+(NSPredicate *)predicateForEpisodesOnToday{
	NSDate *startOfToday = nil;
	NSDate *endOfToday = nil;
	[TCTVEpisode getStartOfToday:&startOfToday endOfToday:&endOfToday];
	
	return [NSPredicate predicateWithFormat:@"(airDate >= %@) AND (airDate <= %@)",startOfToday,endOfToday];
}

+(NSPredicate *)predicateForFavoriteShowsOnToday{
	NSDate *startOfToday = nil;
	NSDate *endOfToday = nil;
	[TCTVEpisode getStartOfToday:&startOfToday endOfToday:&endOfToday];
	
	return [NSPredicate predicateWithFormat:@"(show.favorite == TRUE) AND (airDate >= %@) AND (airDate <= %@)",startOfToday,endOfToday];	
}

+(NSPredicate *)predicateForNonfavoriteShowsOnToday{
	NSDate *startOfToday = nil;
	NSDate *endOfToday = nil;
	[TCTVEpisode getStartOfToday:&startOfToday endOfToday:&endOfToday];
	
	return [NSPredicate predicateWithFormat:@"(show.favorite == FALSE) AND (airDate >= %@) AND (airDate <= %@)",startOfToday,endOfToday];	
}

-(id)copyWithZone:(NSZone *)zone{
	NSLog(@"CopyWithZone!");
	return self;
}

+(NSArray *)episodesForPredicate:(NSPredicate *)predicate{
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"TVEpisode" inManagedObjectContext:moc];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	[request setPredicate:predicate];
	
	NSSortDescriptor *favoriteDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"show.favorite" ascending:NO] autorelease];
	NSSortDescriptor *dateDescriptor     = [[[NSSortDescriptor alloc] initWithKey:@"airDate" ascending:YES] autorelease];
	[request setSortDescriptors:[NSArray arrayWithObjects:favoriteDescriptor, dateDescriptor,nil]];
	
	NSArray *items = [moc executeFetchRequest:request error:nil];
	return items;
}

+(NSArray *)episodesOnToday{
	return [TCTVEpisode episodesForPredicate:[self predicateForEpisodesOnToday]];
}

-(void)loadMetadata{
	
}

-(NSString *)episodeID{
	return [NSString stringWithFormat:([[self episodeNumber] intValue] < 10 ? @"%@x0%@" : @"%@x%@"), [self seasonNumber], [self episodeNumber]];
}

-(void)awakeFromFetch{
	[super awakeFromFetch];
	[self addObservers];
}

-(void)awakeFromInsert{
	[super awakeFromInsert];
	[self addObservers];
}

-(void)addObservers{
	[self addObserver:self
		   forKeyPath:@"show.favorite"
			  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
			  context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([keyPath isEqualToString:@"show.favorite"]){
//		NSLog(@"Favorite changed for %@ - %@",[[self show] showName],change);
		id oldVal = [change valueForKey:NSKeyValueChangeNewKey];
		id newVal = [change valueForKey:NSKeyValueChangeOldKey];
		
		BOOL oldValue = ([oldVal respondsToSelector:@selector(boolValue)] ? [oldVal boolValue] : NO);
		BOOL newValue = ([newVal respondsToSelector:@selector(boolValue)] ? [newVal boolValue] : NO);
		if(newValue != oldValue){
			if(newValue == NO){
				NSLog(@"Saving calendar event");
				[self createCalendarEvent];
			}else{
				NSLog(@"Deleting calendar event");
			}
		}
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

-(void)deleteCalendarEvent{
	if(![self calendarEvent]) return;
	return;
}

-(void)createCalendarEvent{
	/*
	if([self calendarEvent]) return;
	
	TCCalendarEvent *event = [TCCalendarEvent calendarEventWithName:[NSString stringWithFormat:@"%@ - %@",[[self show] showName], [self episodeName]]
														forCalendar:TCCommonCalendar 
													 createIfNeeded:YES];
	
	NSDate *airDate = [self airDate];
	[[event calendarEvent] setStartDate:airDate];
	[[event calendarEvent] setEndDate:[[[NSDate alloc] initWithTimeInterval:60*30 sinceDate:airDate] autorelease]];
	[event saveCalendarEvent];
	
	[self setValue:event forKey:@"calendarEvent"];
	 */
}

@end
