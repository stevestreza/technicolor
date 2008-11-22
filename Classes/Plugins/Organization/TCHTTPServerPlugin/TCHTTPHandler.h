//
//  TCHTTPHandler.h
//  Technicolor
//
//  Created by Steve Streza on 11/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TCHTTPHandler : NSOperation {
	NSString *mRegex;
	
	id mTarget;
	SEL mSelector;
	
	id mConnection;
}

@property (readonly) NSString     *regex;
@property (readonly) NSInvocation *invocation;
@property (assign  ) id            connection;
@end
