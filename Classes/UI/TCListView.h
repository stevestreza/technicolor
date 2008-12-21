//
//  TCListView.h
//  Technicolor
//
//  Created by Steve Streza on 12/20/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TCListView : NSView {
	NSScrollView *mParentScrollView;
	
	NSMutableArray *mRows;
	NSUInteger selectedRow;
}

@property NSUInteger selectedRow;
@property (readonly) NSScrollView *scrollView;

-(void)addRow:(NSView *)row;
-(void)insertRow:(NSView *)row atIndex:(NSUInteger)index;

-(void)removeRowAtIndex:(NSUInteger)index;
-(void)removeAllRows;

-(NSRect)frameForRowAtIndex:(NSUInteger)index;
-(NSSize)totalContentSize;

-(NSUInteger)indexOfPoint:(NSPoint)pt;
-(NSIndexSet *)displayingRows;

-(void)drawGridInRect:(NSRect)theRect;
-(void)drawGridLineAtY:(float)y width:(float)width;
-(void)drawSelectedBackgroundInRect:(NSRect)rect;

@end
