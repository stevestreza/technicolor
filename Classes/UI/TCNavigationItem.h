//
//  TCNavigationItem.h
//  Technicolor
//
//  Created by Steve Streza on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TCNavigationItem : NSObject {
	NSViewController *viewController;
	
	NSString *title;
	NSView *titleView;
	
	NSString *backButtonTitle;
	NSButton *backButton;
	
	NSString *leftButtonTitle;
	NSButton *leftButton;
	
	NSString *rightButtonTitle;
	NSButton *rightButton;
}

@property (readonly) NSViewController *viewController;

@property (copy) NSString *title;
@property (retain) NSView *titleView;

@property (copy) NSString *backButtonTitle;
@property (retain) NSButton *backButton;

@property (copy) NSString *leftButtonTitle;
@property (retain) NSButton *leftButton;

@property (copy) NSString *rightButtonTitle;
@property (retain) NSButton *rightButton;

@end
