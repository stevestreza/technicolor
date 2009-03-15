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

#import "TCTVShow.h"

#import "TVRageController.h"

@implementation TCTVShow

+(NSString *)entityName{
	return @"TVShow";
}

+(TCTVShow *)showWithName:(NSString *)name{
	return [self showWithName:name inContext:[[NSApp delegate] managedObjectContext]];
}

+(TCTVShow *)showWithName:(NSString *)name inContext:(NSManagedObjectContext *)moc{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"(showName == %@)", name];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"showName" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	[sortDescriptor release];
	
	NSError *error = nil;
	NSArray *array = [TCTVShow arrayForPredicate:predicate sortDescriptors:sortDescriptors error:&error];
	
	if (array == nil || array.count == 0)
	{
//		NSLog(@"Creating show on %@ thread",([NSThread isMainThread] ? @"main" : @"NOT MAIN"));
		TCTVShow *newShow = [NSEntityDescription insertNewObjectForEntityForName:@"TVShow"
														  inManagedObjectContext:moc];
		[newShow setValue:name forKey:@"showName"];
				
		return newShow;
	}
	else return [array objectAtIndex:0];
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
		   forKeyPath:@"favorite"
			  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
			  context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([keyPath isEqualToString:@"favorite"]){
		NSLog(@"Favorite changed for %@ - %@",[self valueForKey:@"showName"],[self valueForKey:@"favorite"]);
//		[TCJobQueue beginLoadOperation:TCTVRageGetEpisodesOperation withInfoObject:self delegate:nil];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

-(void)loadEpisodeMetadata{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tvrage.com/%@/episode_list/all",[self valueForKey:@"showName"]]];
	
}

-(NSArray *)episodesInSeason:(NSUInteger)seasonNumber{
	return [self episodesInSeason:seasonNumber withFiles:YES];
}

-(NSArray *)episodesInSeason:(NSUInteger)seasonNumber withFiles:(BOOL)withFiles{
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(show == %@) AND (seasonNumber == %i)",self,seasonNumber];
	if(withFiles){
		pred = [NSCompoundPredicate andPredicateWithSubpredicates:
				[NSArray arrayWithObjects:
				 pred,
				 [NSPredicate predicateWithFormat:@"videoFiles.@count > 0"],
				 nil]
				];
	}
	
	NSError *err = nil;
	NSArray *allShows = [TCTVEpisode arrayForPredicate:pred sortDescriptors:nil error:&err];
	if(err) NSLog(@"OMGWTF %@",err);
	return allShows;	
}


#pragma mark Common Queries

+(NSArray *)allShows:(BOOL)onlyWithFiles{
	NSPredicate *pred = nil;
	if(onlyWithFiles){
		pred = [NSPredicate predicateWithFormat:@"episodes.videoFiles.@count > 0"];
	}
	
	NSError *err = nil;
	NSArray *allShows = [TCTVShow arrayForPredicate:pred sortDescriptors:nil error:&err];
	if(err) NSLog(@"OMGWTF %@",err);
	return allShows;
}

+(NSArray *)arrayForPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors error:(NSError **)errPtr{
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"TVShow" inManagedObjectContext:moc];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	[request setPredicate:predicate];
	[request setSortDescriptors:sortDescriptors];
	
	NSError *error = nil;
	NSArray *array = nil;
	@synchronized(moc){
		array =[moc executeFetchRequest:request error:&error];
	}
	if(error){
		*errPtr = error;
		return nil;
	}else{
		return array;
	}
}

@end
