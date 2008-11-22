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

#import "TCTVEpisode.h"
#import "TCTVShow.h"

@implementation TCTVEpisode

+(TCTVEpisode *)showVideoWithEpisodeName:(NSString *)name season:(int)season episodeNumber:(int)episode show:(TCTVShow *)show{
	if([[show valueForKey:@"numberOfSeasons"] intValue] < season){
		[show setValue:[NSNumber numberWithInt:season] forKey:@"numberOfSeasons"];
	}	
	
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
		
	// Set example predicate and sort orderings...
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"((show.showName == %@) AND (seasonNumber == %i) AND (episodeNumber == %i))", [show showName], season, episode];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"season" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	[sortDescriptor release];
	
	NSError *error = nil;
	NSArray *array = [TCTVEpisode arrayForPredicate:predicate sortDescriptors:sortDescriptors error:&error];
	
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

#ifdef TCTVEpisodeFavoritesEnabled
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
#endif 

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
	
#ifdef TCTVEpisodeFavoritesEnabled
	NSSortDescriptor *favoriteDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"show.favorite" ascending:NO] autorelease];
#endif
	
	NSSortDescriptor *dateDescriptor     = [[[NSSortDescriptor alloc] initWithKey:@"airDate" ascending:YES] autorelease];
	
	[request setSortDescriptors:[NSArray arrayWithObjects:
#ifdef TCTVEpisodeFavoritesEnabled
								 favoriteDescriptor, 
#endif
								 dateDescriptor,nil]];
	
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
#ifdef TCTVEpisodeFavoritesEnabled
	[self addObserver:self
		   forKeyPath:@"show.favorite"
			  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
			  context:nil];
#endif
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
#ifdef TCTVEpisodeFavoritesEnabled
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
#endif
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
#ifdef TCTVEpisodeFavoritesEnabled
	}
#endif
}

+(NSArray *)allEpisodes:(BOOL)onlyWithFiles{
	NSPredicate *pred = nil;
	if(onlyWithFiles){
		pred = [NSPredicate predicateWithFormat:@"videoFiles.@count > 0"];
	}
	
	NSError *err = nil;
	NSArray *allShows = [TCTVEpisode arrayForPredicate:pred sortDescriptors:nil error:&err];
	if(err) NSLog(@"OMGWTF %@",err);
	return allShows;
}

+(NSArray *)arrayForPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors error:(NSError **)errPtr{
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"TVEpisode" inManagedObjectContext:moc];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	[request setPredicate:predicate];
	[request setSortDescriptors:sortDescriptors];
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	if(error){
		*errPtr = error;
		return nil;
	}else{
		return array;
	}
}


@end
