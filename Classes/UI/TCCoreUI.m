//
//  TCCoreUI.m
//  Technicolor
//
//  Created by Steve Streza on 12/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCCoreUI.h"
#import "TCCoreUtils.h"

@implementation TCCoreUI

static BOOL sIsInitted = NO;

+(void)initUI{
	if(!sIsInitted){
		sIsInitted = YES;
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//		NSString *frameworkPath=[bundle pathForResource:@"BWToolkitFramework" ofType:@"framework"];
		NSString *frameworkPath = [[bundle bundlePath] stringByAppendingPathComponent:@"Versions/Current/Frameworks/"];
		frameworkPath = [frameworkPath stringByAppendingPathComponent:@"BWToolkitFramework.framework"];
	
		[TCCoreUtils loadFrameworkAtPath: frameworkPath];
	}
}

@end
