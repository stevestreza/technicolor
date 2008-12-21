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

#import "TCCoreUtils.h"


@implementation TCCoreUtils

static NSBundle *coreBundle = nil;
+(NSBundle *)coreBundle{
	if(!coreBundle){
		coreBundle = [[NSBundle bundleForClass:[TCCoreUtils class]] retain];
	}
	return coreBundle;
}

+(NSManagedObjectModel *)coreModel{
	return [NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[TCCoreUtils coreBundle]]];
}

+(NSManagedObjectContext *)newStoreContext{
	NSManagedObjectContext *sharedContext = [[NSApp delegate] managedObjectContext];
	NSPersistentStoreCoordinator *storeCoordinator = [sharedContext persistentStoreCoordinator];
		
	NSManagedObjectContext *ourContext = [[NSManagedObjectContext alloc] init];
	[ourContext setPersistentStoreCoordinator:storeCoordinator];
	[ourContext setUndoManager:nil];	
	
	return [ourContext autorelease];
}

+(NSArray *)_filetypes{
	return [NSArray arrayWithObjects:
			@"bytes",
			@"KB",
			@"MB",
			@"GB",
			@"TB",
			nil];
}

+(NSString *)formattedStringForFileSize:(TCFileSize)filesize{
	NSArray *types = [TCCoreUtils _filetypes];
	NSUInteger typeIndex = 0;
	for(typeIndex; typeIndex < types.count; typeIndex++){
		if(pow(1024,typeIndex+1) >= filesize){
			break;
		}
	}
	
	double finalValue = (filesize / pow(1024,typeIndex));
	NSString *retValue = [NSString stringWithFormat:@"%0.1f %@",finalValue, [types objectAtIndex:typeIndex]];
	return retValue;	
}

@end
