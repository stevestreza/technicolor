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
		TCVideoFile *newVideoFile = [NSEntityDescription insertNewObjectForEntityForName:@"VideoFile" 
																  inManagedObjectContext:moc];
		[newVideoFile setValue:path forKey:@"path"];

		return newVideoFile;
	}
	else return [array objectAtIndex:0];
}

-(void)awakeFromFetch{
	metadata = [[NSMutableDictionary dictionary] retain];
}

-(void)dealloc{
	[metadata release];
	[super dealloc];
}

-(NSString *)filename{
	return [[[self path] lastPathComponent] stringByDeletingPathExtension];
}

-(id)copyWithZone:(id)whatev{
	return self;
}

-(NSArray *)_filetypes{
	return [NSArray arrayWithObjects:
			@"bytes",
			@"KB",
			@"MB",
			@"GB",
			@"TB",
			nil];
}

-(NSString *)fileSizeString{
	unsigned long long filesize = [self filesize];
	
	NSArray *types = [self _filetypes];
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

-(unsigned long long)filesize{
	NSString *path = [self path];
	
	NSDictionary *attrs = [[NSFileManager defaultManager] fileAttributesAtPath:path traverseLink:YES];
	if(attrs){
		return [[attrs objectForKey:NSFileSize] unsignedLongLongValue];
	}
	return 0;
}

@end
