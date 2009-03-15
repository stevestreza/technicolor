//
//  TCDataStore.m
//  Technicolor
//
//  Created by Steve Streza on 2/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TCDataStore.h"


@implementation TCDataStore

-(id)initWithContext:(NSManagedObjectContext *)ctx{
	if(self = [super init]){
		context = [ctx retain];
	}
	return self;
}

-(void)dealloc{
	[context release];
	[super   dealloc];
}

-(id)createObjectForClass:(Class)factory withOptions:(NSDictionary *)options shouldAdd:(BOOL)shouldAdd{
	id entity = [NSEntityDescription insertNewObjectForEntityForName:[[factory entity] name] 
											  inManagedObjectContext:nil];
	
	for(NSString *key in [options allKeys]){
		[entity setValue:[options valueForKey:key] 
				  forKey:key];
	}
		
	if(shouldAdd){
		[context insertObject:entity];
	}
	
	return entity;
}

-(NSArray *)readObjectForClass:(Class)factory 
				 withPredicate:(NSPredicate *)predicate 
		   withSortDescriptors:(NSArray *)sortDescriptors{
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[[factory entity] name] 
														 inManagedObjectContext:context];
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	
	[request setEntity:entityDescription];
	[request setPredicate:predicate];
	
	[request setSortDescriptors:sortDescriptors];
	
	NSArray *items = nil;
	@synchronized(context){
		items = [context executeFetchRequest:request error:nil];
	}
	return items;	
}

-(id)objectForClass:(Class)factory withValues:(NSDictionary *)options createIfNeeded:(BOOL)createIfNeeded{
	NSMutableString *predicateFormat = [NSMutableString stringWithString:@"("];
	for(NSString *key in [options allKeys]){
		[predicateFormat appendString:key];
		[predicateFormat appendString:@" == %@) AND ("];
	}
	predicateFormat = [predicateFormat substringToIndex:([predicateFormat length] - [@" AND (" length])];
	
	NSLog(@"Predicate format: %@",predicateFormat);
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:predicateFormat
										   argumentArray:[options allValues]];
	NSLog(@"Created %@ for fmt %@",pred, predicateFormat);
	
	id object = [self readObjectForClass:factory withPredicate:pred withSortDescriptors:nil];
	
	if(!object && createIfNeeded){
		object = [self createObjectForClass:factory 
								withOptions:options 
								  shouldAdd:YES];
	}
	return object;
}

@end
