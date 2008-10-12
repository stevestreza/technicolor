//
//  TCTVShow.m
//  Technicolor
//
//  Created by Steve Streza on 8/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCTVShow.h"

#import "TVRageController.h"

@implementation TCTVShow

+(TCTVShow *)showWithName:(NSString *)name{
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"TVShow" inManagedObjectContext:moc];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	// Set example predicate and sort orderings...
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"(showName == %@)", name];
	[request setPredicate:predicate];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"showName" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
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

@end
