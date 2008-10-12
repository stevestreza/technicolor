//
//  TCCalendarEvent.h
//  Sweeps
//
//  Created by Steve Streza on 9/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CalendarStore/CalendarStore.h>
#import "TCCalendar.h"

@interface TCCalendarEvent : NSManagedObject {
	CalEvent *event;
}

+(TCCalendarEvent *)calendarEventWithName:(NSString *)name forCalendar:(TCCalendar *)calendar createIfNeeded:(BOOL)create;

@end
