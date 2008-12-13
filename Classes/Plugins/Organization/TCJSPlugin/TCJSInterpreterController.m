//
//  TCJSInterpreterController.m
//  Technicolor
//
//  Created by Steve Streza on 12/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCJSInterpreterController.h"


@implementation TCJSInterpreterController

-(id)initWithInterpreter:(JSXObjCInterpreter *)interpreter{
	if(self = [super initWithNibName:@"TCJSInterpreter" bundle:[NSBundle bundleForClass:[self class]]]){
		mInterpreter = [interpreter retain];
		mEditor = [[JSXObjCEditor alloc] initWithInterpreter:mInterpreter textView:mTextView];
	}
	return self;
}

-(NSString *)title{
	return @"JS Interpreter";
}

-(IBAction)runScript:(id)sender{
	NSLog(@"Run!");
	
	NSString *script = [mTextView string];
	NSError *err = nil;
	
	id retval = [mInterpreter evaluateScript:script error:&err];
	
	if(err){
		NSLog(@"Error running script! %@",err);
	}else if(!retval){
		NSLog(@"Ran script, retval: %@",retval);
	}else{
		NSLog(@"Ran script, no error, no retval");
	}
}

@end
