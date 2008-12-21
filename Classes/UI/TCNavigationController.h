//
//  TCNavigationController.h
//  Technicolor
//
//  Created by Steve Streza on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TCNavigationBar.h"

@interface TCNavigationController : NSViewController {
	NSMutableArray *navigationStack;
	
	IBOutlet TCNavigationBar *navigationBar;
	IBOutlet NSView *navigationView;
}

-(id)initWithRootViewController:(NSViewController *)controller;

-(void)pushViewController:(NSViewController *)controller animated:(BOOL)animated;
-(id)popViewControllerAnimated:(BOOL)animated;

@end
