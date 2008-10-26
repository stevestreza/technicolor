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

+(CFUUIDRef)generateUUID{
	CFUUIDRef ref = CFUUIDCreate(NULL);
	return ref;
}

-(id)init{
	if(self = [super init]){
		
	}
	return self;
}

-(void)awake{
	
}

-(CFUUIDRef)uuid{
	CFUUIDRef uuid = [TCOrganizationPlugin generateUUID];
	NSString *uuidString = (NSString *)CFUUIDCreateString(NULL, uuid);
	NSLog(@"Store this UUID! %@",uuidString);
	return uuid;
}

@end
