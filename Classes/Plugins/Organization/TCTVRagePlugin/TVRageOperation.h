//
//  TVRageOperation.h
//  Technicolor
//
//  Created by Steve Streza on 9/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TCTVEpisode.h"
#import "TCTVShow.h"
#import <WebKit/WebKit.h>
#import "TCTVRageImports.h"
#import "TNSWDownload.h"

@class TVRageController;

@interface TVRageOperation : NSOperation {
	TCTVRageOperationType operationType;
	id delegate;
	id dataObject;
	
	WebView *webView;
}

-(id)initWithOperation:(TCTVRageOperationType)opType dataObject:(id)obj delegate:(id)del;

-(void)loadAllShows;
-(void)loadEpisodesForShow:(TCTVShow *)show;
-(void)loadInfoForEpisode:(TCTVEpisode *)episode;

+(NSURL *)quickInfoURLForShow:(TCTVShow *)show;
+(NSURL *)quickInfoURLForEpisode:(TCTVEpisode *)episode;

-(NSDictionary *)quickInfoForURL:(NSURL *)url;
-(void)parseLine:(NSString *)line forKey:(NSString **)keyPtr value:(NSString **)valuePtr;
-(void)parseEpisodeID:(NSString *)episodeID withSeason:(NSUInteger *)seasonPtr episode:(NSUInteger *)episodePtr;
@end
