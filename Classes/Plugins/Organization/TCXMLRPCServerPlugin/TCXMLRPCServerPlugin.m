//
//  TCXMLRPCServerPlugin.m
//  Technicolor
//
//  Created by Steve Streza on 11/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCXMLRPCServerPlugin.h"
#import "SimpleHTTPConnection.h"


@implementation TCXMLRPCServerPlugin

TCUUID(@"67049703-4944-4B96-9F5D-6BE83B954821")

-(void)awake{
	server = [[XMLRPCServer alloc] initWithTCPPort:14156];
	[server addMethodNamed:@"getShows" forTarget:self selector:@selector(getShows:)];
}

-(void)getShows:(SimpleHTTPConnection *)conn{
	[conn replyWithStatusCode:200 headers:nil body:[[NSString stringWithFormat:@"Epic win!\n"] dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
