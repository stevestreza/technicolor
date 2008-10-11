//
//  TCFFMPEGVideo.m
//  Technicolor
//
//  Created by Steve Streza on 8/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCFFMPEGVideo.h"
#import "TCFFMPEGInfoOperation.h"

@implementation TCFFMPEGVideo

-(void)addInfoJob{
//	NSLog(@"Adding info job");
	if([[NSFileManager defaultManager] fileExistsAtPath:[self path]]){
		[TCJobQueue addOperation:[[[TCFFMPEGInfoOperation alloc] initWithVideo:self] autorelease]];
	}		
}

@end
