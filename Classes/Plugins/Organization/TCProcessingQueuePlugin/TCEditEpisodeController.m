//
//  TCEditEpisodeController.m
//  Technicolor
//
//  Created by Steve Streza on 12/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCEditEpisodeController.h"
#import "TCEditorProxy.h"

@implementation TCEditEpisodeController

@synthesize videoFile=mEpisode, editor=mEditor;

-(id)init{
	if(self = [super initWithNibName:@"TCEditTVEpisode" bundle:[NSBundle bundleForClass:[TCEditEpisodeController class]]]){
		[self _addObservers];
	}
	return self;
}

-(void)_addObservers{
	[self addObserver:self
		   forKeyPath:@"videoFile" 
			  options:0 
			  context:nil];
}

-(void)_rebuildEditor{
	TCEditorProxy *proxy = [TCEditorProxy proxyForObject:mEpisode];
	
	[self willChangeValueForKey:@"editor"];
	[proxy retain];
	[mEditor release];
	mEditor = proxy;
	[self  didChangeValueForKey:@"editor"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([keyPath isEqualToString:@"videoFile"]){
		NSLog(@"Editor changed");
		[self _rebuildEditor];
	}else{
		[super observeValueForKeyPath:keyPath
							 ofObject:object
							   change:change
							  context:context];
	}
}

@end
