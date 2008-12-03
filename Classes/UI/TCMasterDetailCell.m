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

static NSDictionary *sPrimaryAttribtues   = nil;
static NSDictionary *sSecondaryAttributes = nil;

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
	
	if(!sPrimaryAttribtues){
		sPrimaryAttribtues = [[NSDictionary dictionaryWithObjectsAndKeys:
							  [[NSFontManager sharedFontManager] convertFont:[NSFont systemFontOfSize:12.] toHaveTrait:NSBoldFontMask], NSFontAttributeName,
							  nil] retain];
	}
	
	if(!sSecondaryAttributes){
		sSecondaryAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:
//								 [[NSFontManager sharedFontManager] convertFont:
																				[NSFont systemFontOfSize:11.]
//																	toHaveTrait:NSBoldFontMask]
									, NSFontAttributeName,
								 [NSColor colorWithCalibratedWhite:0.35 alpha:1], NSForegroundColorAttributeName,
							  nil] retain];
	}
	
	[primaryString drawInRect:NSRectFromCGRect(primaryRect) withAttributes:sPrimaryAttribtues];
	[secondaryString drawInRect:NSRectFromCGRect(secondaryRect) withAttributes:sSecondaryAttributes];
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
