//
//  XMLRPCServer.h
//  Technicolor
//
//  Created by Steve Streza on 11/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SimpleHTTPServer.h"

@interface XMLRPCServer : SimpleHTTPServer {
	NSDictionary *methodDictionary;
	
	NSOperationQueue *handlerQueue;
}

- (id)initWithTCPPort:(unsigned)po;

-(NSString *)methodNameForXMLDocument:(NSXMLDocument *)document error:(NSError **)err;
@end
