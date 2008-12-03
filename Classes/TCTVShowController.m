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

#import "TCTVShowController.h"
#import "TCTVShow.h"
#import "TCTVEpisode.h"

#import "TCVideoFile.h"

@implementation TCTVShowController

-(void)awakeFromNib{
	filesCell = [[TCMasterDetailCell alloc] init];
	
	filesCell.primaryKey = @"filename";
	filesCell.secondaryKey = @"fileSizeString";
	
	[[[filesTable tableColumns] objectAtIndex:1] setDataCell:filesCell];
}

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

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex{
	if(aTableView == episodesTable){
		return YES;
	}else if(aTableView == filesTable){
		return NO;
	}
	return NO;
}

@end
