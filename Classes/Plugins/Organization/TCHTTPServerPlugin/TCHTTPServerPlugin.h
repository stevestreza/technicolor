//
//  TCHTTPServerPlugin.h
//  Technicolor
//
//  Created by Steve Streza on 11/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TCCore/TCOrganizationPlugin.h>
#import "Technicolor.h"

#import "TCHTTPServer.h"

@interface TCHTTPServerPlugin : TCOrganizationPlugin {
	TCHTTPServer *server;
}

-(TCHTTPServer *)server;

@end
