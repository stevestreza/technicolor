//
//  TCListView.m
//  Technicolor
//
//  Created by Steve Streza on 12/20/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCListView.h"

@interface TCListView (Private)

-(void)_wrapWithScrollView;
-(void)_updateScrollView;

@end


@implementation TCListView

@synthesize scrollView=mParentScrollView, selectedRow;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		selectedRow = NSNotFound;

		mRows = [[NSMutableArray alloc] init];
		[self _wrapWithScrollView];
    }
    return self;
}

-(void)_wrapWithScrollView{
	mParentScrollView = [[NSScrollView alloc] initWithFrame:[self frame]];
	self.frame = mParentScrollView.bounds;
	[[mParentScrollView contentView] addSubview:self];
}

-(void)addRow:(NSView *)row{
	[self insertRow:row atIndex:mRows.count];
}

-(void)insertRow:(NSView *)row atIndex:(NSUInteger)index{
	if(index > mRows.count) index = mRows.count - 1;
	
	[mRows insertObject:row atIndex:index];
	[self addSubview:row];
	[row setFrame:[self frameForRowAtIndex:index]];
	[row setAutoresizingMask:(NSViewWidthSizable | NSViewMaxYMargin)];
	
	[self _updateScrollView];
}

-(void)removeAllRows{
	while(mRows.count > 0) [self removeRowAtIndex:0];
}
	
-(void)removeRowAtIndex:(NSUInteger)index{
	if(index >= mRows.count) index = mRows.count - 1;
	
	[mRows removeObjectAtIndex:index];
	[[[self subviews] objectAtIndex:index] removeFromSuperview];
	
	[self _updateScrollView];
}

-(NSRect)frameForRowAtIndex:(NSUInteger)index{
	if(index > mRows.count){
		return NSZeroRect;
	}
	
	NSView *indexedRow = [mRows objectAtIndex:index];
	NSRect frame = indexedRow.frame;
	frame.origin.y = 0;
	frame.size.width = self.bounds.size.width;

	NSUInteger loopIndex=0;
	for(loopIndex; loopIndex<index; loopIndex++){
		NSView *view = [mRows objectAtIndex:loopIndex];
		frame.origin.y += view.frame.size.height + 1;
	}
	return NSIntegralRect(frame);
}

-(BOOL)isFlipped{
	return YES;
}

-(void)mouseDown:(NSEvent *)e{
	
}

-(void)mouseUp:(NSEvent *)e{
	NSPoint location = [self convertPoint:[e locationInWindow] fromView:nil];
	self.selectedRow = [self indexOfPoint:location];
}

-(NSUInteger)indexOfPoint:(NSPoint)pt{
	if(mRows.count == 0) return NSNotFound;
	
	NSUInteger index = 0;
	for(index; index < mRows.count; index++){
		NSRect rect = [(NSView *)[mRows objectAtIndex:index] frame];
		if(NSPointInRect(pt, rect)){
			return index;
		}
	}
}

-(void)_updateScrollView{
	NSSize size = [self totalContentSize];
	size.width = self.frame.size.width;
	[self setFrameSize:size];
}

-(NSSize)totalContentSize{
	//we can cheat here and assume all views are in the correct location
	NSView *view = [mRows lastObject];
	NSSize frameSize = view.frame.size;
	
	frameSize.height = view.frame.origin.y + frameSize.height;
	return frameSize;
}

-(NSIndexSet *)displayingRows{
	NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
	
	if(mRows.count == 0) goto finish_index_set;
	
	NSRect bounds = [self superview].bounds;
	
	NSUInteger index = 0;
	for(index; index < mRows.count; index++){
		NSRect frame = [self frameForRowAtIndex:index];
		if(NSIntersectsRect(bounds, frame)){
			[set addIndex:index];
		}else if([set count] > 0){
			goto finish_index_set;
		}
	}
	
finish_index_set:
	return [[set copy] autorelease];
}

-(void)drawRect:(NSRect)theRect{
	if(selectedRow != NSNotFound){
		NSRect selectionFrame = [self frameForRowAtIndex:selectedRow];
		
		if(NSIntersectsRect(selectionFrame, theRect)){
			[self drawSelectedBackgroundInRect:selectionFrame];
		}
	}
	
	[self drawGridInRect:theRect];
}

-(void)drawGridInRect:(NSRect)theRect{
	NSIndexSet *set = [self displayingRows];
	if([set count] == 0) return;
	
	NSUInteger index = [set firstIndex];
	if(index == NSNotFound) return;
	
	[[NSColor grayColor] setStroke];
	do{
		NSRect frame = [self frameForRowAtIndex:index];
		if(frame.size.height < 1) break;
		float line = frame.origin.y + frame.size.height;
		
		[self drawGridLineAtY:line width:frame.size.width];
		
		index = [set indexGreaterThanIndex:index];
	}while(index != [set lastIndex]);
}

-(void)drawGridLineAtY:(float)y width:(float)width{
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(0,y+0.5)];
	[path lineToPoint:NSMakePoint(width,y+0.5)];
	
	[[NSColor lightGrayColor] setStroke];
	[path stroke];
}

//Override to provide custom cell selection behavior
-(void)drawSelectedBackgroundInRect:(NSRect)rect{
	[[NSColor selectedControlColor] setFill];
	[NSBezierPath fillRect:rect];
}

-(void)setSelectedRow:(NSUInteger)newRow{
	selectedRow = newRow;
	[self setNeedsDisplay:YES];
}

@end
