//
//  TCMasterDetailCell.m
//  Technicolor
//
//  Created by Steve Streza on 12/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCMasterDetailCell.h"


@implementation TCMasterDetailCell

@synthesize primaryKey, secondaryKey;

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
	id obj = [self objectValue];
	
	NSString *primaryString = [obj valueForKey:primaryKey];
	if(![primaryString isKindOfClass:[NSString class]]){
		primaryString = [primaryString description];
	}
	
	NSString *secondaryString = [obj valueForKey:secondaryKey];
	if(![secondaryString isKindOfClass:[NSString class]]){
		secondaryString = [secondaryString description];
	}
	
	CGRect primaryRect = CGRectZero;
	CGRect secondaryRect = CGRectZero;
	
	CGRectDivide(NSRectToCGRect(cellFrame), &primaryRect, &secondaryRect, (cellFrame.size.height/2.), CGRectMinYEdge);
	
	[primaryString drawInRect:NSRectFromCGRect(primaryRect) withAttributes:nil];
	[secondaryString drawInRect:NSRectFromCGRect(secondaryRect) withAttributes:nil];
}

- (void)setObjectValue:(id )object {
	id oldObjectValue = [self objectValue];
	if (object != oldObjectValue) {
		[object retain];
		[oldObjectValue release];
		[super setObjectValue:[NSValue valueWithNonretainedObject:object]];
	}
}

- (id)objectValue {
	return [[super objectValue] nonretainedObjectValue];
}

@end
