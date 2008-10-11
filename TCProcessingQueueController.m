//
//  TCProcessingQueueController.m
//  Technicolor
//
//  Created by Steve Streza on 9/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCProcessingQueueController.h"
//#import "hb.h"

@implementation TCProcessingQueueController

//static hb_handle_t *sHBHandle = NULL;

+(void)initialize{
	setenv("HB_DEBUG","true",1);
}


-(id)init{
	if(self = [super initWithNibName:@"ProcessingQueue" bundle:nil]){
		
	}
	return self;
}

-(NSView *)view{
	id theView = [super view];
	NSLog(@"View: %@",theView);
	return theView;
}

-(IBAction)go:(id)sender{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel runModal];
	
	NSString *path = [[openPanel filenames] objectAtIndex:0];
	
//	if(!sHBHandle){
//		sHBHandle = hb_init_dl(HB_DEBUG_ALL, 0);
//	}
	
	char *pathString = [path UTF8String];
	
//	hb_scan(sHBHandle,pathString,0);
}

@end
