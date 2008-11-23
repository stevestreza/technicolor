//
//  TCHTTPHandler.h
//  Technicolor
//
//  Created by Steve Streza on 11/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TCHTTPConnection.h"

@interface TCHTTPHandler : NSOperation {
	NSString *mRegex;
	
	id mTarget;
	SEL mSelector;
	
	TCHTTPConnection *mConnection;
}

@property (readonly) NSString     *regex;
@property (readonly) NSInvocation *invocation;
@property (retain) TCHTTPConnection *connection;
@end
