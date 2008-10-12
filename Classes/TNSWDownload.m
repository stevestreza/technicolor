//
//  TNSWDownload.m
//  InnerTube
//
//  Created by Syco on 9/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TNSWDownload.h"

@implementation TNSWDownload

static BOOL debugCacheEnabled = YES;

-(id)initWithURL:(NSURL *)theURL{
	return [self initWithURL:theURL name:@"Unknown Download"];
}

-(id)initWithURL:(NSURL *)theURL name:(NSString *)name image:(NSImage *)img{
	self = [super init];
	if(self){
		downloadName = [name retain];
		downloadImage= [img retain];
		if(downloadImage && downloadName){
//			[[DownloadManagerController sharedManager] addProcess:self];
		}
		url = [theURL retain];
		
		dataReceived = NO;
		if(debugCacheEnabled){
			NSString *cachePath = [TNSWDownload debugCachePathForURL:url];
			data = [[[NSFileManager defaultManager] contentsAtPath:cachePath] retain];
		}
		
		if(!data){
			request = [[NSURLRequest alloc] initWithURL:url
											cachePolicy:NSURLRequestReturnCacheDataElseLoad
										timeoutInterval:300.0];
		}
									
		if(downloadImage && downloadName){
			//Insignificant.
//			[[DownloadManagerController sharedManager] addProcess:self];
		}
	}
	return self;
}

+(NSString *)debugCachePathForURL:(NSURL *)url{
	NSString *relativePath = [[url host] stringByAppendingPathComponent:[url path]];
	relativePath = [[[[NSApp delegate] applicationSupportFolder] stringByAppendingPathComponent:@"DebugCache"] stringByAppendingPathComponent:relativePath];
	NSUInteger questionMarkLocation = [[url absoluteString] rangeOfString:@"?"].location;
	
	if(questionMarkLocation != NSNotFound){
		NSString *fileName = [[url absoluteString] substringFromIndex:questionMarkLocation + 1];
		relativePath = [relativePath stringByAppendingPathComponent:fileName];
	}
	
//	NSLog(@"URL %@ path: %@",url,relativePath);
	return relativePath;
}

+(NSString *)loadResourceStringForURL:(NSURL *)url encoding:(NSStringEncoding)encoding{
	return [[[NSString alloc] initWithData:[TNSWDownload loadResourceDataForURL:url] encoding:encoding] autorelease];
}

+(NSData *)loadResourceDataForURL:(NSURL *)url{
	return [self loadResourceDataForURL:url withName:nil image:nil progressBar:nil notify:nil];
}

+(NSData*)loadResourceDataForURL:(NSURL*)url
                           image:(NSImage*)img
                        withName:(NSString*)name{
	return [self loadResourceDataForURL:url withName:name image:img progressBar:nil notify:nil];
}

+(NSData*)loadResourceDataForURL:(NSURL*)url
                     progressBar:(NSProgressIndicator*)newBar{
	return [self loadResourceDataForURL:url withName:nil image:nil progressBar:newBar notify:nil];
}

+(NSData*)loadResourceDataForURL:(NSURL*)url
                          notify:(id)notif{
	return [self loadResourceDataForURL:url withName:nil image:nil progressBar:nil notify:notif];
}

+(NSData*)loadResourceDataForURL:(NSURL*)url
                        withName:(NSString*)name
                           image:(NSImage*)img
                     progressBar:(NSProgressIndicator*)newBar
                          notify:(id)notif{
	@try{
		TNSWDownload *download = [[TNSWDownload alloc] initWithURL:url name:name image:img];
		[download setProgressBar:newBar];
		[download setNotify:notif];
		NSData *downloadedData = [download data];
		[download release];
		return downloadedData;
	}
	@catch(NSException *e){
//		TNSWLog(@"Loading error: %@",e);
		return nil;
	}
}

-(void)setNotify:(id)notif{
	[notif retain];
	[notify release];
	notify = notif;
}

- (NSProgressIndicator *)progressBar
{
	return progressBar;
}

- (void)setProgressBar:(NSProgressIndicator *)aValue
{
	NSProgressIndicator *oldProgressBar = progressBar;
	progressBar = [aValue retain];
	[oldProgressBar release];
}

-(NSData *)data{
	if(!data){
		[self performSelectorOnMainThread:@selector(beginLoadingData) withObject:nil waitUntilDone:YES];
		[self loadData];
	}
	return data;
}

-(void)beginLoadingData{
	connection = [[NSURLConnection alloc] initWithRequest:request
										delegate:self];
	
	//dataLength = [ intValue];
	[self updateProgressBar];
}

-(void)loadData{
	if(connection){
		NSString *obj;
		
		data = [[NSMutableData alloc] initWithCapacity:6000];
		isConnected = YES;
		hasError = NO;
		fullyLoaded = NO;
		while(!fullyLoaded){
			[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
		}
	}
}

-(void)dealloc{
//	[[DownloadManagerController sharedManager] removeProcess:self];
	[url release];
	[request release];
	[error release];
	[progressBar release];
	[downloadName release];
	[super dealloc];
}

-(NSString *)name{
	return downloadName;
}

- (NSImage *)image
{
	return downloadImage;
}

-(void)updateProgressBar{
	if(progressBar){
		[progressBar setMinValue:0];
		[progressBar setMaxValue:dataLength];
		[progressBar setDoubleValue:[data length]];
		[progressBar display];
	}
	if(notify){
		[notify setDownloadLength:dataLength];
		[notify setDownloadedAmount:[data length]];
	}
}

#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection*)connection
  didFailWithError:(NSError*)deadError
{
    // release the connection, and the data object
    [connection release];
    [data release];
	
    connection = nil;
    data = nil;
    
	hasError = YES;
	isConnected = NO;
	fullyLoaded = YES;
	
    // inform the user
//    TNSWLog(@"Connection failed! Error - %@ %@",
//          [deadError localizedDescription],
//          [[deadError userInfo] objectForKey:NSErrorFailingURLStringKey]);
	error = deadError;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{
    // append the new data to the receivedData
	if(!dataReceived){
		dataReceived = YES;
		//dataLength = 
	}
	[data appendData:theData];
	[self updateProgressBar];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    //TNSWLog(@"Succeeded! Received %d bytes of data",[data length]);
	
    // release the connection, and the data object
    [connection release];
	connection = nil;
	hasError = NO;
	isConnected = NO;
	fullyLoaded = YES;
	
	if(debugCacheEnabled){
		NSString *cachePath = [TNSWDownload debugCachePathForURL:url];
		[[NSFileManager defaultManager] createDirectoryAtPath:[cachePath stringByDeletingLastPathComponent] 
								  withIntermediateDirectories:YES 
												   attributes:nil 
														error:nil];
		[[NSFileManager defaultManager] createFileAtPath:cachePath 
												contents:data 
											  attributes:nil];
	}
}

-(NSURLRequest *)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse
{
//	TNSWLog(@"sending request %@",request);
	return request;
}


-(void)connection:(NSURLConnection *)conn didReceiveResponse:(NSHTTPURLResponse *)response{
//	TNSWLog(@"Response: %i %@ %@",[response statusCode],[request URL],[response allHeaderFields]);
	if([response statusCode] == 303 && [[response allHeaderFields] valueForKey:@"Location"]){
		[self updateToURL:[NSURL URLWithString:[[response allHeaderFields] valueForKey:@"Location"]]];
	}
	int length = (int)[response expectedContentLength];
	dataLength = length;
	[self updateProgressBar];
}

-(void)updateToURL:(NSURL *)url{
	[NSThread detachNewThreadSelector:@selector(updateToURLThreaded:)
						toTarget:self
					   withObject:url];
}

-(void)updateToURLThreaded:(NSURL *)url{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[connection cancel];
	[connection release];
	connection = nil;
	[data release];
	data = nil;
	[request release];
	request = [[NSURLRequest alloc] initWithURL:url
							  cachePolicy:NSURLRequestReturnCacheDataElseLoad
						   timeoutInterval:300.0];
	[self performSelectorOnMainThread:@selector(beginLoadingData) withObject:nil waitUntilDone:YES];
	[self loadData];
	[pool release];
}

@end
