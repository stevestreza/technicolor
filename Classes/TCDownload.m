//
//  TCDownload.m
//  Technicolor
//
//  Created by Steve Streza on 10/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCDownload.h"


@implementation TCDownload

@synthesize 
delegate=mDelegate, 
url=mURL, 
request=mRequest, 
response=mResponse,  
data=mData,  
requestType=mRequestType,  
requestData=mRequestData,  
finished=mFinished,
expectedSize=mExpectedSize;

+(NSString *)loadResourceStringForURL:(NSURL *)url encoding:(NSStringEncoding)encoding{
	return [[[NSString alloc] initWithData:[TCDownload loadResourceDataForURL:url] encoding:encoding] autorelease];
}

+(NSData *)loadResourceDataForURL:(NSURL *)url{
	TCDownload *download = [[TCDownload alloc] initWithURL:url];
	[download send];
	while(!download.finished){
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	}
	NSData *data = [download.data retain];
	[download release];
	return data;
}

-(id)initWithURL:(NSURL *)url{
	if(self = [super init]){
		mURL = [url copy];
		mFinished = NO;
	}
	return self;
}

-(void)setValue:(id)value forHeader:(NSString *)headerKey{
	if(mHeaders){
		mHeaders = [[NSMutableDictionary alloc] init];
	}
	[mHeaders setValue:value forKey:headerKey];
}

-(NSString *)_HTTPMethodName{
	switch (mRequestType) {
		case TCDownloadRequestTypeGET:
			return @"GET";
			break;
		case TCDownloadRequestTypePOST:
			return @"POST";
			break;
		case TCDownloadRequestTypeHEAD:
			return @"HEAD";
			break;
		default:
			break;
	}
	return @"GET";
}

-(NSURLRequest *)_buildRequest{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:mURL];
	[request setHTTPMethod:[self _HTTPMethodName]];

	if(mHeaders){
		NSArray *keys = [mHeaders allKeys];
		for(NSString *key in keys){
			id value = [mHeaders valueForKey:key];
			[request addValue:value forHTTPHeaderField:key];
		}
	}
	
	if(mRequestData){
		[request setHTTPBody:mRequestData];
	}
	
	return [request autorelease];
}

-(void)send{
	mRequest = [[self _buildRequest] retain];
	mConnection = [[NSURLConnection connectionWithRequest:mRequest delegate:self] retain];
	[mConnection start];
}

-(void)cancel{
	[mConnection cancel];
}

- (void)connection:(NSURLConnection*)connection
  didFailWithError:(NSError*)deadError{
	
	if(mDelegate && [mDelegate respondsToSelector:@selector(download:hadError:)]){
		[mDelegate download:self hadError:deadError];
	}	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData{
	NSMutableData *objectData = (NSMutableData *)mData;
	
	[self willChangeValueForKey:@"data"];
	[objectData appendData:theData];
	[self didChangeValueForKey:@"data"];

	if(mDelegate && [mDelegate respondsToSelector:@selector(downloadReceivedData:)]){
		[mDelegate downloadReceivedData:self];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	if(mDelegate && [mDelegate respondsToSelector:@selector(downloadFinished:)]){
		[mDelegate downloadFinished:self];
	}
}

-(NSURLRequest *)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse{
	//	TNSWLog(@"sending request %@",request);
	return request;
}


-(void)connection:(NSURLConnection *)conn didReceiveResponse:(NSHTTPURLResponse *)response{
	if([response statusCode] == 303 && [[response allHeaderFields] valueForKey:@"Location"]){
		NSLog(@"need a redirect!");
		return;
	}
	mExpectedSize = [response expectedContentLength];
	if(!mData){
		mData = [[NSMutableData alloc] initWithCapacity:(NSUInteger)mExpectedSize];
	}
}

@end
