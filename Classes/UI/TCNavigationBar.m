//
//  TCNavigationBar.m
//  Technicolor
//
//  Created by Steve Streza on 12/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCNavigationBar.h"


@implementation TCNavigationBar

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	[[NSColor redColor] set];
	[NSBezierPath fillRect: [self bounds]];
}

@end
