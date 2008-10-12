//
//  TCOrganizationPlugin.m
//  Technicolor
//
//  Created by Steve Streza on 10/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCOrganizationPlugin.h"


@implementation TCOrganizationPlugin

static NSMutableArray *pluginArray;

+(void)initialize{
	NSLog(@"Initializing %@",[self class]);
}

+(NSManagedObjectModel *)objectModel{
	return [NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle bundleForClass:self]]];
}

-(id)init{
	if(self = [super init]){
		
	}
	return self;
}

-(void)awake{
	
}

@end
