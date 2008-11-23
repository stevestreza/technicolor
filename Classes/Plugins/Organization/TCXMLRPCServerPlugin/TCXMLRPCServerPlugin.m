//
//  TCXMLRPCServerPlugin.m
//  Technicolor
//
//  Created by Steve Streza on 11/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCXMLRPCServerPlugin.h"
#import "TCHTTPConnection.h"
#import "TCOrganizationPluginManager.h"

@implementation TCXMLRPCServerPlugin

TCUUID(@"67049703-4944-4B96-9F5D-6BE83B954821")

-(void)awake{
	id plugin = [[TCOrganizationPluginManager sharedPluginManager] pluginWithUUID:kTCHTTPServerPluginUUID];
	id rootServer = [plugin server];
	server = [[XMLRPCServer alloc] initWithHTTPServer:rootServer];
	
	[self loadHandlers];
}

-(void)loadHandlers{
	if(!handlers){
		handlers = [[NSArray arrayWithObjects:
					 [[[TCXMLRPCTVEpisodeHandler alloc] init] autorelease],
					 nil] retain];
					
		
		for(id handler in handlers){	
			NSString *name = [handler name];
			NSMutableDictionary *namespace = [server addNamespaceNamed:name];

			NSArray *handlerNames = [handler methodNames];
			for(NSString *handlerName in handlerNames){
				[server addMethodNamed:[NSString stringWithFormat:@"%@.%@",name,handlerName] 
							 forTarget:handler 
							  selector:[handler selectorForMethodNamed:handlerName]];
			}
		}
	}
}

-(void)getShows:(TCHTTPConnection *)conn{
	[conn replyWithStatusCode:200 headers:nil body:[[NSString stringWithFormat:@"Epic win!\n"] dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
