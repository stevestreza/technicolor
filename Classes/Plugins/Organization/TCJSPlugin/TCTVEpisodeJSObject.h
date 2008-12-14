//
//  TCTVEpisodeJSObject.h
//  Technicolor
//
//  Created by Steve Streza on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TCTVShowJSObject.h"
#import "JSXObjCBridgeObject.h"
#import "TCTVEpisode.h"
#import "TCTVShow.h"

@interface TCTVEpisodeJSObject : JSXObjCBridgeObject {
	TCTVEpisode *episode;
}

@end
