//
//  TCCalendarEventEvent.m
//  Sweeps
//
//  Created by Steve Streza on 9/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCCalendarEvent.h"


@implementation TCCalendarEvent

+(TCCalendarEvent *)calendarEventWithName:(NSString *)name forCalendar:(TCCalendar *)calendar createIfNeeded:(BOOL)create{
	CalEvent *realEvent = nil;
	
	@try {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title == %@) AND (calendar.uid == %@)" 
													argumentArray:[NSArray arrayWithObjects:name,[calendar uid],nil]];
	
		NSArray *array = [[CalCalendarStore defaultCalendarStore] eventsWithPredicate:predicate];
		if([array count] > 0){
			NSLog(@"Events: %@",array);
			realEvent = [array objectAtIndex:0];
		}else NSLog(@"No events found");
	}
	@catch (NSException * e) {
		NSLog(@"Exception: %@",e);
	}
	
	if(!realEvent && create){
		NSLog(@"Creating real event");
		realEvent = [CalEvent event];
		realEvent.title = name;
		realEvent.calendar = [calendar calendar];
		
	}
	
	if(!realEvent) return nil;
	NSLog(@"Creating core data object");
	return [self calendarEventWithStoreCalendarEvent:realEvent forCalendar:calendar];
}

+(TCCalendarEvent *)calendarEventWithUID:(NSString *)uid calendar:(TCCalendar *)calendar{
	CalEvent *realEvent = [[CalCalendarStore defaultCalendarStore] eventWithUID:uid occurrence:nil];
	if(!realEvent) return nil;
	if(calendar && [calendar calendar] != [realEvent calendar]) return nil;
	
	return [self calendarEventWithStoreCalendarEvent:realEvent forCalendar:calendar];
}

+(TCCalendarEvent *)calendarEventWithStoreCalendarEvent:(CalEvent *)calendarEvent forCalendar:(TCCalendar *)calendar{
	NSString *uid = [calendarEvent uid];
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"TCCalendarEvent" inManagedObjectContext:moc];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	// Set example predicate and sort orderings...
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"(uid == %@)", uid];
	[request setPredicate:predicate];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"uid" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	if (array == nil || array.count == 0)
	{
		//		NSLog(@"Creating show on %@ thread",([NSThread isMainThread] ? @"main" : @"NOT MAIN"));
		TCCalendarEvent *newCalendarEvent = [NSEntityDescription insertNewObjectForEntityForName:@"TCCalendarEvent"
																inManagedObjectContext:moc];
		[newCalendarEvent setValue:calendar forKey:@"calendar"];
		[newCalendarEvent _setCalendarEvent:calendarEvent];
		
		return newCalendarEvent;
	}
	else return [array objectAtIndex:0];
}

-(void)_setCalendarEvent:(CalEvent *)cal{
	[cal retain];
	[event release];
	event = cal;
	
	NSString *uid = [cal uid];
	[self setValue:uid forKey:@"uid"];
}

-(CalEvent *)calendarEvent{
	if(!event){
		event = [[CalCalendarStore defaultCalendarStore] eventWithUID:[self uid] occurrence:nil];
	}
	return event;
}

-(void)saveCalendarEvent{
	NSError *err = nil;
	NSLog(@"saving calendar event");
	if(![[CalCalendarStore defaultCalendarStore] saveEvent:[self calendarEvent] span:CalSpanThisEvent error:&err]){
		NSLog(@"Couldn't save new calendarEvent %@ %@ - %@",[[self calendarEvent] title],[self calendarEvent],err);
	}else{
		NSLog(@"Save successful: %@ %@ - %@",[[self calendarEvent] title],[[self calendarEvent] startDate],[[self calendarEvent] endDate]);
	}
}

@end
