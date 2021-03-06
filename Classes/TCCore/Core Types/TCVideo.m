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

#import "TCVideo.h"

@implementation TCVideo

+(NSString *)entityName{
	return @"Video";
}

+(NSArray *)videosForPredicate:(NSPredicate *)predicate{
	return [self videosForPredicate:predicate withSortDescriptors:[NSArray array]];
}

+(NSArray *)videosForPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDescriptors{
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[[self entity] name] 
														 inManagedObjectContext:moc];
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	
	[request setEntity:entityDescription];
	[request setPredicate:predicate];
	
	[request setSortDescriptors:sortDescriptors];
	
	NSArray *items = nil;
	@synchronized(moc){
		items = [moc executeFetchRequest:request error:nil];
	}
	return items;
}

+(NSPredicate *)predicateForVideosWithFiles{
	return [NSPredicate predicateWithFormat:@"videoFiles.@count > 0"];
}

-(void)addFile:(TCVideoFile *)videoFile{
	NSMutableSet *files = [self mutableSetValueForKey:@"videoFiles"];
	[files addObject:videoFile];
}

-(TCVideoFile *)anyFile{
	return [[self valueForKey:@"videoFiles"] anyObject];
}

@end
