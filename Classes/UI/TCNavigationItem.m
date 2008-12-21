//
//  TCNavigationItem.m
//  Technicolor
//
//  Created by Steve Streza on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCNavigationItem.h"


@implementation TCNavigationItem

@synthesize title, titleView, 
	backButtonTitle, backButton, 
	leftButtonTitle, leftButton, 
	rightButtonTitle, rightButton,
	viewController;

-(id)initWithViewController:(NSViewController *)controller{
	if(self = [super init]){
		viewController = [controller retain];
	}
	return self;
}

@end
