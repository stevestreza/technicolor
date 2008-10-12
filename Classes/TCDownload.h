//
//  TCDownload.h
//  Technicolor
//
//  Created by Steve Streza on 10/12/08.
//

#import <Foundation/Foundation.h>

@class TCDownload;

@protocol TCDownloadDelegate

-(void)downloadReceivedData:(TCDownload *)download;
-(void)downloadFinished:(TCDownload *)download;
-(void)download:(TCDownload *)download hadError:(NSError *)error;

@end

typedef long long TCDownloadSize;

typedef enum {
	TCDownloadRequestTypeGET,
	TCDownloadRequestTypePOST,
	TCDownloadRequestTypeHEAD
} TCDownloadRequestType;

@interface TCDownload : NSObject {
	id<TCDownloadDelegate> mDelegate;
	
	NSURL *mURL;
	NSURLRequest *mRequest;
	NSHTTPURLResponse *mResponse;
	NSURLConnection *mConnection;
	NSDictionary *mHeaders;
	
	TCDownloadRequestType mRequestType;
	TCDownloadSize mExpectedSize;
	
	NSData *mRequestData;
	NSData *mData;
	
	BOOL mFinished;
}

@property (assign) id<TCDownloadDelegate> delegate;
@property (readonly) NSURL *url;
@property (readonly) NSURLRequest  *request;
@property (readonly) NSHTTPURLResponse *response;
@property (readonly) NSData *data;
@property (retain) NSData *requestData;
@property TCDownloadRequestType requestType;
@property (readonly) TCDownloadSize expectedSize;
@property (readonly, getter=isFinished) BOOL finished;

-(id)initWithURL:(NSURL *)url;

-(void)send;
-(void)cancel;

+(NSData *)loadResourceDataForURL:(NSURL *)url;
+(NSString *)loadResourceStringForURL:(NSURL *)url encoding:(NSStringEncoding)encoding;
@end
