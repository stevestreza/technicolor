//
//  TCTVShowJSBridge.m
//  Technicolor
//
//  Created by Steve Streza on 12/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCTVShowJSBridge.h"
#import "TCCoreUtils.h"

#import "TCTVShow.h"

#import "TCTVShowJSObject.h"

@implementation TCTVShowJSBridge

+ (NSArray *) objectPropertyNames{ // for KVO.  Note that property access goes through KVO
//	NSLog(@"objectPropertyNames");
    return [NSArray arrayWithObjects: @"allShows",@"allEpisodes",nil];
}

+ (BOOL) canWriteProperty: (NSString *) propertyName{
	return NO;
}

+ (NSArray *) objectFunctionNames{
//	NSLog(@"ObjectFunctionNames");
	return [NSArray arrayWithObjects: @"createShow",@"createEpisode", @"showNamed",@"fileForPath",nil];
}

+ (NSString *) constructorName{
//	NSLog(@"constructorName");
	return @"TVShowBridge";
}

- (void) awakeFromConstructor: (NSArray *) arguments{
	storeContext = [[TCCoreUtils newStoreContext] retain];
}

-(void)dealloc{
	[storeContext commitEditing];
	[storeContext release];
	
	[super dealloc];
}

#pragma mark Accessors

-(NSArray *)allShows{
	NSArray *allShows = [TCTVShow allShows:NO];
	NSMutableArray *showSet = [NSMutableArray arrayWithCapacity:allShows.count];
	for(TCTVShow *show in allShows){
		TCTVShowJSObject *object = [self bridgeObject:[TCTVShowJSObject class] withConstructorArguments:nil];
		[object _setShow:show];
		
		[showSet addObject:object];
	}
	return showSet;
}

-(NSArray *)allEpisodes{
	return [NSArray arrayWithObjects:@"Woo!",nil];	
}

#pragma mark JavaScript call handlers

- (id) jsxobjcCallCreateShow: (NSArray *) args{
	NSLog(@"Whee!");
	return nil;
}

- (id) jsxobjcCallCreateEpisode: (NSArray *) args{
	NSLog(@"Barf!");
	return nil;
}

-(id) jsxobjcCallFileForPath: (NSArray *)args{
	switch (args.count) {
		case 0:
			return nil;
			break;
		case 1:
			return [self videoFileObjectForPath:[args objectAtIndex:0]];
			break;
		default:
			return nil;
			break;
	}
}

-(TCVideoFileJSObject *)videoFileObjectForPath:(NSString *)path{
	TCVideoFile *videoFile = [TCVideoFile videoFileForPath:path];

	TCVideoFileJSObject *vfObject = [self bridgeObject:[TCVideoFileJSObject class]
							  withConstructorArguments:nil];
	[vfObject _setVideoFile:videoFile];
	
	return vfObject;
}

-(id) jsxobjcCallShowNamed: (NSArray *)args{
	TCTVShow *show = [TCTVShow showWithName:[args objectAtIndex:0] inContext:storeContext];
	
	TCTVShowJSObject *object = [self bridgeObject:[TCTVShowJSObject class] withConstructorArguments:nil];
	[object _setShow:show];
	
	return object;
/*	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [show valueForKey:@"showName"], @"showName",
						  [show valueForKey:@"numberOfSeasons"], @"numberOfSeasons",
						  nil];
	
	return dict;
 */
}

@end
