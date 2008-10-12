//
//  TCCalendar.h
//  Sweeps
//
//  Created by Steve Streza on 9/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CalendarStore/CalendarStore.h>

@interface TCCalendar : NSManagedObject {
	
}

-(CalCalendar *)calendar;
-(void)_setCalendar:(CalCalendar *)cal;

+(TCCalendar *)calendarWithName:(NSString *)name createIfNeeded:(BOOL)create;
+(TCCalendar *)calendarWithUID:(NSString *)uid;
+(TCCalendar *)calendarWithStoreCalendar:(CalCalendar *)calendar;

@end
