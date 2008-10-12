//
//  TCWizardController.m
//  Technicolor
//
//  Created by Steve Streza on 8/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCWizardController.h"


@implementation TCWizardController

-(id)initWithViewController:(NSViewController *)controller{
	if(self = [super initWithWindowNibName:@"Wizard" owner:self]){
		controllerStack = [[NSMutableArray array] retain];
		[controllerStack addObject:controller];
		controllerIndex = 0;
	}
	return self;
}

-(NSMutableArray *)controllerStack{
	return controllerStack;
}

-(void)pushViewController:(NSViewController *)controller animated:(BOOL)animated{
	NSUInteger index = controllerIndex + 1;
	for(index; index < controllerStack.count;){
		[controllerStack removeObjectAtIndex:index];
	}

	[[self controllerStack] addObject:controller];
	[self updateButtons];
}

-(void)selectNext:(id)sender{
	NSViewController *controller = [self selectedViewController];
	NSView *view = [controller view];
	
	[view removeFromSuperview];

	controller = [controllerStack objectAtIndex:++controllerIndex];
	view = [controller view];
	
	contentView.bounds = view.bounds;

	[self updateSizesForView:view];
	[contentView addSubview:view];	
	[self updateButtons];
}

-(void)selectPrevious:(id)sender{
	NSViewController *controller = [self selectedViewController];
	NSView *view = [controller view];
	
	[view removeFromSuperview];
	
	controller = [controllerStack objectAtIndex:--controllerIndex];
	view = [controller view];
	
	[self updateSizesForView:view];
	[contentView addSubview:view];		
	[self updateButtons];
}

-(void)windowDidLoad{
	[super windowDidLoad];
	
	NSLog(@"Window did load");
	
	NSViewController *mainController = [[self controllerStack] objectAtIndex:0];
	NSView *view = [mainController view];
	
	[contentView addSubview:view];
	
	[self updateSizesForView:view];
	[self updateButtons];
}

-(NSViewController *)selectedViewController{
	return [controllerStack objectAtIndex:controllerIndex];
}

-(void)updateSizesForView:(NSView *)childView{
	NSRect windowFrame = [[self window] frame];
	NSSize originalSize = [contentView frame].size;
	NSSize newSize = [childView frame].size;
	
	NSSize delta = NSMakeSize(newSize.width - originalSize.width, newSize.height - originalSize.height);
	windowFrame.size.width  += delta.width;
	windowFrame.size.height += delta.height;
	windowFrame.origin.y    -= delta.height;
	NSLog(@"Old: %@, new: %@, delta: %@, new window frame: %@",NSStringFromSize(originalSize),NSStringFromSize(newSize),NSStringFromSize(delta),NSStringFromRect(windowFrame));
	[[self window] setFrame:windowFrame display:YES animate:YES];
	[contentView setFrame:NSMakeRect(0,buttonBox.frame.size.height+buttonBox.frame.origin.y,newSize.width,newSize.height)];
}

-(void)updateButtons{
	[nextButton setEnabled:(controllerIndex < controllerStack.count -1)];
	[previousButton setEnabled:(controllerIndex > 0)];
	
	NSLog(@"Updated buttons to %@ %@ %i %i",NSStringFromBool([nextButton isEnabled]),NSStringFromBool([previousButton isEnabled]),controllerIndex,controllerStack.count);
}

@end
