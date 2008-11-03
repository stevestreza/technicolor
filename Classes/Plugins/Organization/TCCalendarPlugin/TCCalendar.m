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

#import "TCCalendar.h"


@implementation TCCalendar

+(TCCalendar *)calendarWithName:(NSString *)name createIfNeeded:(BOOL)create{
	CalCalendar *realCalendar = nil;
	NSArray *calendars = [[CalCalendarStore defaultCalendarStore] calendars];
	for(CalCalendar *cal in calendars){
		if([[cal title] isEqualToString:name]){
			realCalendar = cal;
			break;
		}
	}
	
	if(!realCalendar && create){
		realCalendar = [CalCalendar calendar];
		realCalendar.title = name;
		
		NSError *err = nil;
		if(![[CalCalendarStore defaultCalendarStore] saveCalendar:realCalendar error:&err]){
			NSLog(@"Couldn't save new calendar %@ %@ - %@",name,realCalendar,err);
			realCalendar = nil;
		}
	}
	
	if(!realCalendar) return nil;
	
	return [self calendarWithStoreCalendar:realCalendar];
}

+(TCCalendar *)calendarWithUID:(NSString *)uid{
	CalCalendar *realCalendar = [[CalCalendarStore defaultCalendarStore] calendarWithUID:uid];
	if(!realCalendar) return nil;
	
	return [self calendarWithStoreCalendar:realCalendar];
}

+(TCCalendar *)calendarWithStoreCalendar:(CalCalendar *)calendar{
	NSString *uid = [calendar uid];
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"TCCalendar"
														 inManagedObjectContext:moc];
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
		TCCalendar *newCalendar = [NSEntityDescription insertNewObjectForEntityForName:@"TCCalendar"
														  inManagedObjectContext:moc];
		[newCalendar _setCalendar:calendar];
		
		return newCalendar;
	}
	else return [array objectAtIndex:0];
}

-(void)_setCalendar:(CalCalendar *)cal{
	NSString *uid = [cal uid];
	[self setValue:uid forKey:@"uid"];
}

-(CalCalendar *)calendar{
	return [[CalCalendarStore defaultCalendarStore] calendarWithUID:[self uid]];
}

@end
