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

#import "Technicolor_AppDelegate.h"
#import "TCWizardController.h"
#import "TCTVShowController.h"
#import "TCProcessingQueueController.h"
#import "TCCore.h"

@implementation Technicolor_AppDelegate
@synthesize viewControllers, jobQueue;

//@synthesize calendar;

/**
    Returns the support folder for the application, used to store the Core Data
    store file.  This code uses a folder named "Technicolor" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Technicolor"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    NSManagedObjectModel *coreModel = [TCCore coreModel];
	NSManagedObjectModel *pluginModel = [[self organizationPluginManager] pluginModel];
	
	managedObjectModel = [[NSManagedObjectModel modelByMergingModels:[NSArray arrayWithObjects:coreModel,pluginModel,nil]] retain];
	
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The folder for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"Technicolor.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    

    return persistentStoreCoordinator;
}

-(TCOrganizationPluginManager *)organizationPluginManager{
	if(!organizationPluginManager){
		organizationPluginManager = [[TCOrganizationPluginManager alloc] init];
		[organizationPluginManager loadPlugins];
	}
	return organizationPluginManager;
}

-(id)init{
	if(self = [super init]){
		NSViewController *vc;
		
/*		vc = [[NSViewController alloc] init];
		[vc setTitle:@"Movies"];
		[viewControllers addObject:vc];
		[vc release];
		
		vc = [[NSViewController alloc] init];
		[vc setTitle:@"Movie Trailers"];
		[viewControllers addObject:vc];
		[vc release];
*/		
		vc = [[TCTVShowController alloc] initWithNibName:@"TCTVShowView" bundle:nil];
		[vc setTitle:@"TV Shows"];
//		[viewControllers addObject:vc];
		[self addViewController:vc forType:@"Videos"];
		[vc release];
		
		vc = [[TCProcessingQueueController alloc] init];
		[vc setTitle:@"Conversions"];
		[self addViewController:vc forType:@"Workers"];
		[vc release];
/*		
		vc = [[NSViewController alloc] init];
		[vc setTitle:@"Downloads"];
		[viewControllers addObject:vc];
		[vc release];
 */
		
		jobQueue = [[NSOperationQueue alloc] init];
	}
	return self;
}

-(void)addViewController:(NSViewController *)controller forType:(NSString *)type{
	if(!viewControllers){
		viewControllers = [[NSMutableDictionary alloc] init];
	}
	
	NSMutableArray *array = [viewControllers valueForKey:type];
	if(!array){
		array = [[NSMutableArray alloc] init];
		[viewControllers setValue:array forKey:type];
		[array autorelease];
	}
	
	if([array indexOfObject:controller] == NSNotFound){
		[array addObject:controller];
	}
}

-(void)awakeFromNib{
	[viewArrayController addObserver:self forKeyPath:@"selection" options:0 context:nil];
	[self selectViewController:[[viewArrayController selectedObjects] objectAtIndex:0]];
}

-(void)applicationDidFinishLaunching:(NSNotification *)notif{
	[self organizationPluginManager];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)contex{
	if(object == viewArrayController && [keyPath isEqualToString:@"selection"]){
		[self selectViewController:[[viewArrayController selectedObjects] objectAtIndex:0]];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:contex];
	}
}

-(void)selectViewController:(NSViewController *)vc{
	NSView *view = [vc view];
	
	view.frame = contentView.bounds;
	
	if(contentView.subviews.count > 0){
		[(NSView*)([[contentView subviews] objectAtIndex:0]) removeFromSuperview];
	}
	[contentView addSubview:view];
}

#define NSURLString(__str) [NSURL URLWithString:__str]
-(IBAction)addVideos:(id)sender{
/*	NSViewController *vc = [[NSViewController alloc] init];
	NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0,0,480,640)];
	[imageView setImage:[[[NSImage alloc] initWithContentsOfURL:NSURLString(@"http://media.apn.co.nz/webcontent/image/jpg/sm3_wp_spideynoir_480x640.jpg")] autorelease]];
	[vc setView: imageView];
	
	TCWizardController *wizard = [[TCWizardController alloc] initWithViewController:vc];
	
	[vc release];
	[imageView release];
	
	vc = [[NSViewController alloc] init];
	imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0,0,480,640)];
	[imageView setImage:[[[NSImage alloc] initWithContentsOfURL:NSURLString(@"http://media.apn.co.nz/webcontent/image/jpg/sm3_wp_poster_480x640.jpg")] autorelease]];
	[vc setView: imageView];
	
	[wizard showWindow:sender];
	
	[wizard pushViewController:vc animated:YES];*/
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories:YES];
	[openPanel runModal];
	
	NSArray *filenames = [openPanel filenames];
	for(NSString *path in filenames){
		TCVideoFile *video = [TCVideoFile videoFileForPath:path];
//		if([video isKindOfClass:[TCDVDVideo class]]){
//			NSLog(@"DVD!");
//			[(TCDVDVideo *)video loadTitles];
//		}
	}
	
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext != nil) {
        return managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}


/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    NSError *error;
    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.

                // Typically, this process should be altered to include application-specific 
                // recovery steps.  

                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 

                else {
					
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void) dealloc {

    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [super dealloc];
}

- (BOOL)outlineView:(NSOutlineView *)sender isGroupItem:(id)item {
	if ([item isKindOfClass:[NSNumber class]])
		return YES;
	else
		return NO;
}

- (void)outlineView:(NSOutlineView *)sender willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	if ([item isKindOfClass:[NSNumber class]]) {
		NSMutableAttributedString *newTitle = [[cell attributedStringValue] mutableCopy];
		[newTitle replaceCharactersInRange:NSMakeRange(0,[newTitle length]) withString:[[newTitle string] uppercaseString]];
		[cell setAttributedStringValue:newTitle];
		[newTitle release];
	}
}
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(NSNumber *)item{
	if(item == nil){
		return 2;
	}
	return [(NSArray *)[viewControllers valueForKey:[self keyForIndex:[item intValue]]] count];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(NSNumber *)item{
	if(item == nil){
		return [NSNumber numberWithInt:index];
	}
	NSString *key = [self keyForIndex:[item intValue]];
	return [[viewControllers valueForKey:key] objectAtIndex:index];
}

-(NSString *)keyForIndex:(NSUInteger)index{
	switch(index){
		case 0: return @"Videos";
		case 1: return @"Workers";
	};
	return @"";
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
		if([item isKindOfClass:[NSNumber class]]){
			return YES;
		}
	return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
	if([item isKindOfClass:[NSNumber class]]){
		return [self keyForIndex:[item intValue]];
	}
	
	return [item title];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item{
	return ([item isKindOfClass:[NSViewController class]]);
}

-(NSViewController *)selectedViewController{
	if(!selectedViewController){
		NSUInteger count = [viewSelectionList selectedRow];
		NSUInteger index=0; 
		NSUInteger index2=0;
		NSUInteger numberOfGroups = [self outlineView:viewSelectionList numberOfChildrenOfItem:nil];
		
		count --;
		for(index; index < numberOfGroups; index++){
			NSString *key = [self keyForIndex:index];
			NSArray *vcArray = (NSArray *)[viewControllers valueForKey:key];
			for(index2; index2 < [vcArray count]; index2++){
				NSViewController *vc = [vcArray objectAtIndex:index2];
				if(count == 0){
					selectedViewController = vc;
					index = numberOfGroups;
					break;
				}
				count--;
			}
		}
	}
	return selectedViewController;
}

-(void)_updateSelectedViewController{
	selectedViewController = nil;
	[self selectedViewController];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification{
	[self _updateSelectedViewController];
	
	[self selectViewController:[self selectedViewController]];
}

@end
