//
//  TCTVShowJSObject.h
//  Technicolor
//
//  Created by Steve Streza on 12/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JSXObjCBridgeObject.h"
#import "TCTVShow.h"

@interface TCTVShowJSObject : JSXObjCBridgeObject {
	TCTVShow *show;
}

@end
