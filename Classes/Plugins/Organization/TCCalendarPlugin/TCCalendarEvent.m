/*
 
 Copyright (c) 2008 Technicolor Project
 Licensed under the MIT License
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

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
	NSArray *array = nil;
	@synchronized(moc){
		array =[moc executeFetchRequest:request error:&error];
	}
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
