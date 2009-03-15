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

#import "TCMovieVideo.h"


@implementation TCMovieVideo

+(NSString *)entityName{
	return @"MovieVideo";
}

+(NSArray *)allMovies:(BOOL)onlyWithFiles{
	NSPredicate *pred = nil;
	if(onlyWithFiles){
		pred = [NSPredicate predicateWithFormat:@"videoFiles.@count > 0"];
	}
	
//	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"movie.name" ascending:YES] autorelease];
	
	NSError *err = nil;
	NSArray *allShows = [TCMovieVideo arrayForPredicate:pred 
//										sortDescriptors:[NSArray arrayWithObject:sortDescriptor] 
										sortDescriptors:nil
												  error:&err];
	if(err) NSLog(@"OMGWTF %@",err);
	return allShows;
}

+(NSArray *)arrayForPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors error:(NSError **)errPtr{
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"MovieVideo" inManagedObjectContext:moc];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	[request setPredicate:predicate];
	[request setSortDescriptors:sortDescriptors];
	
	NSError *error = nil;
	NSArray *array = nil;	
	@synchronized(moc){
		array = [moc executeFetchRequest:request error:&error];
	}
	if(error){
		*errPtr = error;
		return nil;
	}else{
		return array;
	}
}

@end
