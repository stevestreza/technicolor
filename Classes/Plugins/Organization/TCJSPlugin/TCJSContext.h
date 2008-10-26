//
//  TCJSContext.h
//  Technicolor
//
//  Created by Steve Streza on 10/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JSContextRef.h>

@interface TCJSContext : NSObject {
	JSGlobalContextRef context;
}

@end
