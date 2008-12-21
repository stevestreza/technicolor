//
//  TCNavigationController.m
//  Technicolor
//
//  Created by Steve Streza on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCNavigationController.h"


@implementation TCNavigationController

-(id)initWithRootViewController:(NSViewController *)controller{
	if(self = [super initWithNibName:@"TCNavigationController" bundle:[NSBundle bundleForClass:[TCNavigationController class]]]){
		navigationStack = [[NSMutableArray alloc] init];
		[self pushViewController:controller animated:NO];
	}
}

-(void)pushViewController:(NSViewController *)controller 
				 animated:(BOOL)animated{

	if(navigationStack.count == 0){
		NSLog(@"Initializing navigation view");
		
		NSView *view = [controller view];
		[navigationView addSubview:view];
	}else{
		NSLog(@"Pushing new view controller");
	}
}

-(id)popViewControllerAnimated:(BOOL)animated{
	NSLog(@"Popping view controller");
	return nil;
}

@end
