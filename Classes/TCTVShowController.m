//
//  TCTVShowController.m
//  Technicolor
//
//  Created by Steve Streza on 8/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCTVShowController.h"
#import "TCTVShow.h"
#import "TCTVEpisode.h"

#import "TCVideoFile.h"

@implementation TCTVShowController

-(IBAction)import:(id)sender{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];

	[openPanel beginSheetForDirectory:@"/Volumes/Lavos/Video/TV Shows/"
								 file:nil
					   modalForWindow:[[self view] window] 
						modalDelegate:self 
					   didEndSelector:@selector(importPanel:didReturn:contextInfo:)
						  contextInfo:nil];
	
//	[NSApp beginSheet:openPanel modalForWindow:<#(NSWindow *)docWindow#> modalDelegate:<#(id)modalDelegate#> didEndSelector:<#(SEL)didEndSelector#> contextInfo:<#(void *)contextInfo#>
}

-(void)importPanel:(NSOpenPanel *)openPanel didReturn:(int)returnCode contextInfo:(void*)hahaWhoCares{
	NSArray *sourceDirectories = [openPanel filenames];
	[self threadedLoadDirectories:sourceDirectories];
}

-(void)threadedLoadDirectories:(NSArray *)sourceDirectories{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	
	[TCJobQueue setSuspended:YES];
	
	for(NSString *path in sourceDirectories){
		if([[path lastPathComponent] isEqualToString:@"VIDEO_TS"]){
			TCVideoFile *video = [TCVideoFile videoFileForPath:path];
			[NSThread detachNewThreadSelector:@selector(loadTitles) toTarget:video withObject:nil];
		}else{
			NSArray *shows = [fm directoryContentsAtPath:path];
			for(NSString *showName in shows){
				if([showName isEqualToString:@"24"]) continue;
				if([showName isEqualToString:@"My Name Is Earl"]) continue;
				if([showName isEqualToString:@"The Venture Bros."]) continue;
				
				TCTVShow *show = [TCTVShow showWithName:showName];
				//			NSLog(@"Found show: %@",showName);
				NSString *showPath = [path stringByAppendingPathComponent:showName];
				
				NSArray *seasons = [fm directoryContentsAtPath:showPath];
				for(NSString *seasonName in seasons){
					NSUInteger seasonNumber = [[seasonName stringByReplacingOccurrencesOfString:@"Season " withString:@""] intValue];
					//				NSLog(@"-Found season %i",seasonNumber);
					NSString *seasonPath = [showPath stringByAppendingPathComponent:seasonName];
					
					NSArray *episodes = [fm directoryContentsAtPath:seasonPath];
					for(NSString *episodeName in episodes){
						int spaceIndex = [episodeName rangeOfString:@" "].location;
						if(spaceIndex == NSNotFound) continue;
						NSString *episodeNumberString = [episodeName substringToIndex:spaceIndex];
						
						int episodeNumber = [[episodeNumberString substringFromIndex:spaceIndex-2] intValue];
						int nameIndex = [[episodeName substringFromIndex:spaceIndex+1] rangeOfString:@" "].location;
						if(nameIndex == NSNotFound) continue;
						nameIndex += spaceIndex + 1;
						NSString *episodeTitle = [[episodeName substringFromIndex:nameIndex] stringByDeletingPathExtension];
						
						//					NSLog(@"--Found %i %i - %@",seasonNumber,episodeNumber,episodeTitle);
						
						//					NSLog(@"Meta! Show: %@, Episode: %i %i, %@",showName, seasonNumber, episodeNumber, episodeTitle);
						TCTVEpisode *video = [TCTVEpisode showVideoWithEpisodeName:episodeTitle season:seasonNumber episodeNumber:episodeNumber show:show];
						
						TCVideoFile *videoFile = [TCVideoFile videoFileForPath:[seasonPath stringByAppendingPathComponent:episodeName]];
						//					NSLog(@"---Found video file %@",[videoFile valueForKey:@"path"]);
						//					[(NSMutableSet *)[video valueForKey:@"videoFiles"] addObject:videoFile];
						[videoFile setVideo:video];
					}
				}
			}
		}
	}	

	[TCJobQueue setSuspended:NO];
	
	[pool release];
}

@end
