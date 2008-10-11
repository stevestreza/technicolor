//
//  TNSWDownload.h
//  InnerTube
//
//  Created by Syco on 9/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TNSWDownload : NSObject {
	
	NSString *downloadName;
	NSImage *downloadImage;

	NSURL			*url;
	NSURLConnection *connection;
	NSURLRequest    *request;
	NSMutableData   *data;
	NSError			*error;
	
	NSProgressIndicator *progressBar;
	int dataLength;
	
	BOOL isConnected;
	BOOL hasError;
	BOOL fullyLoaded;
	
	BOOL dataReceived;
	
	id notify;
	
}


-(id)initWithURL:(NSURL *)theURL;
-(id)initWithURL:(NSURL *)theURL name:(NSString *)name;
+(NSData *)loadResourceDataForURL:(NSURL *)url;
+(NSString *)loadResourceStringForURL:(NSURL *)url encoding:(NSStringEncoding)encoding;
-(NSData *)data;
-(void)beginLoadingData;
-(void)loadData;
-(void)dealloc;
-(NSString *)name;

@end
