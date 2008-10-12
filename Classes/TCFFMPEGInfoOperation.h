//
//  TCFFMPEGInfoOperation.h
//  Technicolor
//
//  Created by Steve Streza on 8/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TCFFMPEGVideo.h"

#import <libavformat/avformat.h>

@interface TCFFMPEGInfoOperation : NSOperation {
	TCFFMPEGVideo *video;
}

@end
