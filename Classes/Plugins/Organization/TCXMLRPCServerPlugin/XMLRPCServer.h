//
//  XMLRPCServer.h
//  Technicolor
//
//  Created by Steve Streza on 11/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "SimpleHTTPServer.h"

@interface XMLRPCServer : NSObject {
	NSDictionary *methodDictionary;
	id rootServer;
	NSOperationQueue *handlerQueue;
}

-(NSString *)methodNameForXMLDocument:(NSXMLDocument *)document error:(NSError **)err;
-(NSDictionary *)namespaceForPath:(NSString *)namespacePath createIfNecessary:(BOOL)createIfNecessary;
@end
