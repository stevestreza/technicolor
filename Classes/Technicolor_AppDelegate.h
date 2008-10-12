//
//  Technicolor_AppDelegate.h
//  Technicolor
//
//  Created by Steve Streza on 8/11/08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

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
