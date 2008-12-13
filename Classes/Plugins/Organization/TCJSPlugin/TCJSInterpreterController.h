//
//  TCJSInterpreterController.h
//  Technicolor
//
//  Created by Steve Streza on 12/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "JSXObjCInterpreter.h"
#import "JSXObjCEditor.h"

@interface TCJSInterpreterController : NSViewController {
	JSXObjCInterpreter *mInterpreter;
	JSXObjCEditor *mEditor;
	
	IBOutlet NSTextView *mTextView;
	IBOutlet NSTableView *mConsoleView;
}

-(id)initWithInterpreter:(JSXObjCInterpreter *)interpreter;
-(IBAction)runScript:(id)sender;

@end
