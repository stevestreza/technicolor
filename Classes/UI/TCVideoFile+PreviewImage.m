//
//  TCVideoFile+PreviewImage.m
//  Technicolor
//
//  Created by Steve Streza on 12/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCVideoFile+PreviewImage.h"


@implementation  TCVideoFile (PreviewImage)

-(NSImage *)previewImage{
	if([metadata objectForKey:@"previewImage"]) return [metadata objectForKey:@"previewImage"];
	
	[NSThread detachNewThreadSelector:@selector(getPreviewImage:) toTarget:self withObject:self];

	if(![self path]) return nil;
	return [[NSWorkspace sharedWorkspace] iconForFile:[self path]];
}

-(void)getPreviewImage:(id)sender{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	NSImage *image = [self generatePreviewImage];
	if(image){
		NSLog(@"Saving image!");
		[self willChangeValueForKey:@"previewImage"];
		[metadata setObject:image forKey:@"previewImage"];
		[self didChangeValueForKey:@"previewImage"];
		NSLog(@"Done saving image!");
	}
	
	[pool release];
}

-(NSImage *)generatePreviewImage{
	NSSize size = NSMakeSize(512, 512);
	
	NSString *thePath = [self path];
	if(!thePath) return nil;
	
	NSURL *fileURL = [NSURL fileURLWithPath:thePath];
	if (!fileURL) {
		return nil;
	}
	
	NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] 
													 forKey:(NSString *)kQLThumbnailOptionIconModeKey];
	CGImageRef ref = QLThumbnailImageCreate(kCFAllocatorDefault, 
											(CFURLRef)fileURL, 
											CGSizeMake(size.width, size.height),
											(CFDictionaryRef)dict);
	
	if (ref != NULL) {
		// Take advantage of NSBitmapImageRep's -initWithCGImage: initializer, new in Leopard,
		// which is a lot more efficient than copying pixel data into a brand new NSImage.
		// Thanks to Troy Stephens @ Apple for pointing this new method out to me.
		NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:ref];
		NSImage *newImage = nil;
		if (bitmapImageRep) {
			newImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
			[newImage addRepresentation:bitmapImageRep];
			[bitmapImageRep release];
			
			if (newImage) {
				return [newImage autorelease];
			}
		}
		CFRelease(ref);
	} else {
		// If we couldn't get a Quick Look preview, fall back on the file's Finder icon.
		NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:thePath];
		if (icon) {
			[icon setSize:size];
		}
		return icon;
	}
	
	return nil;
}

@end
