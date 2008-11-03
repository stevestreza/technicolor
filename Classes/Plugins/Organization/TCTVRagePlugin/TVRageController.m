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
