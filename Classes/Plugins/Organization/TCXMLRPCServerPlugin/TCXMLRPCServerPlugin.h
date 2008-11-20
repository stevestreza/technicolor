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

@interface TCXMLRPCServerPlugin : TCOrganizationPlugin {
	XMLRPCServer *server;
}

@end
