//
//  TCVideoFile.m
//  Technicolor
//
//  Created by Steve Streza on 8/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

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
