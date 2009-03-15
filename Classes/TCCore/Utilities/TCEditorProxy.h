//
//  TCEditorProxy.h
//  Technicolor
//
//  Created by Steve Streza on 2/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TCEditorProxy : NSObject {
	id mObject;
	
	NSMutableDictionary *mKeyChanges;
	NSMutableDictionary *mKeyPathChanges;
	NSMutableDictionary *mUndefKeyChanges;
}

@end
