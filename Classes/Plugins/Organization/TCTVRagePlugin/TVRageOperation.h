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

#import <Cocoa/Cocoa.h>
#import "TCTVEpisode.h"
#import "TCTVShow.h"
#import <WebKit/WebKit.h>
#import "TCTVRageImports.h"
#import "TCDownload.h"

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
