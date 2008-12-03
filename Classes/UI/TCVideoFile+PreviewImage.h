//
//  TCVideoFile+PreviewImage.h
//  Technicolor
//
//  Created by Steve Streza on 12/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TCVideoFile.h"
#import <QuickLook/QuickLook.h>

@interface TCVideoFile (PreviewImage)
-(NSImage *)previewImage;
@end
