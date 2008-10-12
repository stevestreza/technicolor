//
//  TCCore.m
//  Technicolor
//
//  Created by Steve Streza on 10/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCCore.h"


@implementation TCCore

static NSBundle *coreBundle = nil;
+(NSBundle *)coreBundle{
	if(!coreBundle){
		coreBundle = [[NSBundle bundleForClass:[TCCore class]] retain];
	}
	return coreBundle;
}

+(NSManagedObjectModel *)coreModel{
	return [NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[TCCore coreBundle]]];
}

@end
