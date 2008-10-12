//
//  TVRageController.m
//  Technicolor
//
//  Created by Steve Streza on 8/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TVRageController.h"


@implementation TVRageController

static TVRageController *sharedController = nil;

+ (TVRageController*)sharedController
{
	@synchronized(self) {
		if (sharedController == nil) {
			[[self alloc] init]; // assignment not done here
		}
	}
	return sharedController;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedController == nil) {
			sharedController = [super allocWithZone:zone];
			return sharedController;  // assignment and return on first allocation
		}
	}
	return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
	//do nothing
}

- (id)autorelease
{
	return self;
}

-(void)beginLoadOperation:(TCTVRageOperationType)operationType withInfoObject:(id)infoObject delegate:(id)delegate{
	TVRageOperation *op = [[TVRageOperation alloc] initWithOperation:operationType dataObject:infoObject delegate:delegate];
	[((NSOperationQueue *)([[NSApp delegate] jobQueue])) addOperation:op];
	[op release];
}

-(void)loadCurrentDayScheduleWithDelegate:(id)delegate{
	[self beginLoadOperation:TCTVRageGetCurrentDayScheduleOperation withInfoObject:nil delegate:delegate];
}

@end
