//
//  TCJSContext.m
//  Technicolor
//
//  Created by Steve Streza on 10/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCJSContext.h"


@implementation TCJSContext

-(id)initWithContext:(JSContextRef)newContext{
	if(self = [super init]){
		context = JSGlobalContextRetain((JSGlobalContextRef)newContext);
	}
	return self;
}

-(void)dealloc{
	JSGlobalContextRelease(context);
	
	[super dealloc];
}

-(void)collectGarbage{
	JSGarbageCollect(context);
}



@end
