//
//  TCVideoFileJSObject.h
//  Technicolor
//
//  Created by Steve Streza on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JSXObjCBridgeObject.h"
#import "TCVideoFile.h"

@interface TCVideoFileJSObject : JSXObjCBridgeObject {
	TCVideoFile *videoFile;
}

@end
