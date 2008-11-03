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

#import <Cocoa/Cocoa.h>
#import "TCVideoFile.h"
#import "TCDVDVideo.h"
#import "TCCalendar.h"
#import <CalendarStore/CalendarStore.h>

#import "TCOrganizationPluginManager.h"

@interface Technicolor_AppDelegate : NSObject 
{
    IBOutlet NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	IBOutlet NSOutlineView *viewSelectionList;
	IBOutlet NSView *contentView;
	
	NSMutableDictionary *viewControllers;
	IBOutlet NSArrayController *viewArrayController;
	
	NSViewController *selectedViewController;
	
	TCOrganizationPluginManager *organizationPluginManager;
	
	NSOperationQueue *jobQueue;
//	TCCalendar *calendar;
}
@property (readonly) NSOperationQueue *jobQueue;
@property (retain) NSMutableDictionary *viewControllers;
@property (readonly) TCCalendar *calendar;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
-(TCOrganizationPluginManager *)organizationPluginManager;

- (IBAction)saveAction:sender;
-(IBAction)addVideos:(id)sender;
@end
