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

#import "TCVideoFile.h"


@implementation TCVideoFile

+(TCVideoFile *)videoFileForPath:(NSString *)path{
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"VideoFile" inManagedObjectContext:moc];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	// Set example predicate and sort orderings...
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"(path == %@)", path];
	[request setPredicate:predicate];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"showName" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	if (array == nil || array.count == 0)
	{
		TCVideoFile *newVideoFile = nil;
		if([[path lastPathComponent] isEqualToString:@"VIDEO_TS"]){
			newVideoFile = [NSEntityDescription insertNewObjectForEntityForName:@"DVDVideo" 
														 inManagedObjectContext:moc];
		}else{
			newVideoFile = [NSEntityDescription insertNewObjectForEntityForName:@"FFMPEGVideo" 
														 inManagedObjectContext:moc];
		}
		[newVideoFile setValue:path forKey:@"path"];

		if([[[newVideoFile entity] name] isEqualToString:@"FFMPEGVideo"]){
			[(TCFFMPEGVideo *)newVideoFile addInfoJob];
		}
		
		return newVideoFile;
	}
	else return [array objectAtIndex:0];
}
@end
