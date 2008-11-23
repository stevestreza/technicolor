//
//  TCXMLRPCServerPlugin.h
//  Technicolor
//
//  Created by Steve Streza on 11/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Technicolor.h"
#import <TCCore/TCOrganizationPlugin.h>
#import "XMLRPCServer.h"

#import "TCXMLRPCTVEpisodeHandler.h"

#define kTCHTTPServerPluginUUID @"EDD4962D-4BCC-4CF5-A7B0-35FC22E85B09"

@interface TCXMLRPCServerPlugin : TCOrganizationPlugin {
	id server;
	
	NSArray *handlers;
}

@end
