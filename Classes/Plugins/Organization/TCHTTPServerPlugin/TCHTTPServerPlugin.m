//
//  TCHTTPServerPlugin.m
//  Technicolor
//
//  Created by Steve Streza on 11/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCHTTPServerPlugin.h"
#import "TCHTTPConnection.h"

@implementation TCHTTPServerPlugin

TCUUID(@"EDD4962D-4BCC-4CF5-A7B0-35FC22E85B09")

-(void)awake{
	server = [[TCHTTPServer alloc] initWithTCPPort:14156 delegate:self];
	
	[server addHandlerForRegex:@"^\/test\/.*$" target:self selector:@selector(handleTest:)];
}

-(void)handleTest:(TCHTTPConnection *)connection{
	NSLog(@"Epic win.");
	[connection replyWithStatusCode:200 headers:nil body:[@"Epic win!\n" dataUsingEncoding:NSUTF8StringEncoding]];
}

-(TCHTTPServer *)server{
	return server;
}

-(void)stopProcessing{
	
}

@end
