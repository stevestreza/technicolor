//
//  TCDataStore.h
//  Technicolor
//
//  Created by Steve Streza on 2/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TCDataStore : NSObject {
	NSManagedObjectContext *context;
}

//create
-(id)createObjectForClass:(Class)factory 
			  withOptions:(NSDictionary *)options 
				shouldAdd:(BOOL)shouldAdd;

//read
-(NSArray *)readObjectForClass:(Class)factory 
				 withPredicate:(NSPredicate *)predicate 
		   withSortDescriptors:(NSArray *)sortDescriptors;

//create
-(id)objectForClass:(Class)factory withValues:(NSDictionary *)options createIfNeeded:(BOOL)createIfNeeded;

@end
