//
//  TCWizardController.h
//  Technicolor
//
//  Created by Steve Streza on 8/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define NSStringFromBool(__val) (__val == YES ? @"Yes" : @"No")

#define NSStringFromPoint(__pt) [NSString stringWithFormat:@"%ix%i",(int)(__pt.x),(int)(__pt.y)]
#define NSStringFromSize(__size) [NSString stringWithFormat:@"%ix%i",(int)(__size.width),(int)(__size.height)]
#define NSStringFromRect(__rect) [NSString stringWithFormat:@"%@, %@",NSStringFromPoint(__rect.origin), NSStringFromSize(__rect.size)]

@interface TCWizardController : NSWindowController {
	IBOutlet NSButton *nextButton;
	IBOutlet NSButton *previousButton;
	
	IBOutlet NSButton *cancelButton;
	
	IBOutlet NSView *contentView;
	IBOutlet NSBox *buttonBox;
	
	NSMutableArray *controllerStack;
	NSUInteger controllerIndex;
}
-(NSMutableArray *)controllerStack;
-(void)selectPrevious:(id)sender;
-(void)selectNext:(id)sender;
@end
