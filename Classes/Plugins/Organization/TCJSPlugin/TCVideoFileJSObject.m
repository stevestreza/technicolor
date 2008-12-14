//
//  TCVideoFileJSObject.m
//  Technicolor
//
//  Created by Steve Streza on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCVideoFileJSObject.h"


@implementation TCVideoFileJSObject

+ (NSArray *) objectPropertyNames{ // for KVO.  Note that property access goes through KVO
    return [NSArray arrayWithObjects: @"path",nil];
}

+ (BOOL) canWriteProperty: (NSString *) propertyName{
	return NO;
}

+ (NSArray *) objectFunctionNames{
	return [NSArray arrayWithObjects: nil];
}

+ (NSString *) constructorName{
	return @"VideoFile";
}

- (void) awakeFromConstructor: (NSArray *) arguments{
}

-(void)_setVideoFile:(TCVideoFile *)vf{
	[videoFile autorelease];
	videoFile = [vf retain];
}

-(NSString *)path{
	return [videoFile valueForKey:@"path"];
}

@end
