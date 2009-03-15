//
//  TCEditEpisodeController.h
//  Technicolor
//
//  Created by Steve Streza on 12/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TCTVShow.h"
#import "TCTVEpisode.h"
#import "TCVideoFile.h"

@interface TCEditEpisodeController : NSViewController {
	TCVideoFile *mEpisode;
	id mEditor;
}

@property (retain) TCVideoFile *videoFile;
@property (readonly) id editor;

@end
