//
//  TCTVShowJSObject.m
//  Technicolor
//
//  Created by Steve Streza on 12/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCTVShowJSObject.h"
#import "TCTVEpisode.h"
#import "TCTVEpisodeJSObject.h"

@implementation TCTVShowJSObject

+ (NSArray *) objectPropertyNames{ // for KVO.  Note that property access goes through KVO
    return [NSArray arrayWithObjects: @"numberOfSeasons",@"showName",@"episodes",nil];
}

+ (BOOL) canWriteProperty: (NSString *) propertyName{
	return NO;
}

+ (NSArray *) objectFunctionNames{
	return [NSArray arrayWithObjects: nil];
}

+ (NSString *) constructorName{
	return @"TVShow";
}

- (void) awakeFromConstructor: (NSArray *) arguments{
}

-(NSString *)showName{
	return [show valueForKey:@"showName"];
}

-(NSNumber *)numberOfSeasons{
	return [show valueForKey:@"numberOfSeasons"];
}

-(NSArray *)episodes{
	NSSet *sourceEpisodes = [show valueForKey:@"episodes"];
	NSMutableArray *episodes = [NSMutableArray arrayWithCapacity:[sourceEpisodes count]];
	for(TCTVEpisode *episode in sourceEpisodes){
		TCTVEpisodeJSObject *object = [self bridgeObject:[TCTVEpisodeJSObject class]
								withConstructorArguments:[NSArray array]];
		[object _setEpisode:episode];
		[episodes addObject:object];
	}
	return episodes;
}

-(void)_setShow:(TCTVShow *)theShow{
	[show autorelease];
	show = [theShow retain];
}

@end
