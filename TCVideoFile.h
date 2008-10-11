//
//  TCVideoFile.h
//  Technicolor
//
//  Created by Steve Streza on 8/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "TCFFMPEGVideo.h"
@class TCFFMPEGVideo;

@interface TCVideoFile : NSManagedObject {

}

+(TCVideoFile *)videoFileForPath:(NSString *)path;

@end
