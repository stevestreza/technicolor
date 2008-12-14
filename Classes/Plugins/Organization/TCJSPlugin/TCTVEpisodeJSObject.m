//
//  TCTVEpisodeJSObject.m
//  Technicolor
//
//  Created by Steve Streza on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCTVEpisodeJSObject.h"
#import "TCVideoFileJSObject.h"

@implementation TCTVEpisodeJSObject
+ (NSArray *) objectPropertyNames{ // for KVO.  Note that property access goes through KVO
    return [NSArray arrayWithObjects: @"show", @"episodeName",
			@"airDate", @"episodeID", 
			@"seasonNumber", @"episodeNumber",
			@"videoFiles",
			nil];
}

+ (BOOL) canWriteProperty: (NSString *) propertyName{
	return NO;
}

+ (NSArray *) objectFunctionNames{
	return [NSArray arrayWithObjects: nil];
}

+ (NSString *) constructorName{
	return @"TVEpisode";
}

- (void) awakeFromConstructor: (NSArray *) arguments{
}

-(void)_setEpisode:(TCTVEpisode *)ep{
	[ep autorelease];
	episode = [ep retain];
}

-(TCTVShowJSObject *)show{
	TCTVShowJSObject *obj = [self bridgeObject:[TCTVShowJSObject class] withConstructorArguments:[NSArray array]];
	[obj _setShow:[episode valueForKey:@"show"]];
	return obj;
}

-(NSString *)episodeName{
	return [episode valueForKey:@"episodeName"];
}

-(NSString *)episodeID{
	return [episode valueForKey:@"episodeID"];
}

-(NSDate *)airDate{
	return [episode valueForKey:@"airDate"];
}

-(NSNumber *)seasonNumber{
	return [episode valueForKey:@"seasonNumber"];
}

-(NSNumber *)episodeNumber{
	return [episode valueForKey:@"episodeNumber"];
}

-(NSArray *)videoFiles{
	NSSet *sourceFiles = [episode valueForKey:@"videoFiles"];
	NSMutableArray *files = [NSMutableArray arrayWithCapacity:[sourceFiles count]];
	for(TCVideoFile *file in sourceFiles){
		TCVideoFileJSObject *object = [self bridgeObject:[TCVideoFileJSObject class]
								withConstructorArguments:[NSArray array]];
		[object _setVideoFile:file];
		[files addObject:object];
	}
	return files;	
}

@end
