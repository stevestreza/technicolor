//
//  SimpleHTTPConnection.m
//  SimpleCocoaHTTPServer
//
//  Created by Jürgen Schweizer on 13.09.06.
//  Copyright 2006 Cultured Code.
//  License: Creative Commons Attribution 2.5 License
//           http://creativecommons.org/licenses/by/2.5/
//

#import "TCHTTPConnection.h"
#import "TCHTTPServer.h"
#import <netinet/in.h>      // for sockaddr_in
#import <arpa/inet.h>       // for inet_ntoa


@implementation TCHTTPConnection

- (id)initWithFileHandle:(NSFileHandle *)fh delegate:(id)dl
{
    if( self = [super init] ) {
        fileHandle = [fh retain];
        delegate = [dl retain];
		
        isMessageComplete = YES;
        message = NULL;

        // Get IP address of remote client
        CFSocketRef socket;
        socket = CFSocketCreateWithNative(kCFAllocatorDefault,
                                          [fileHandle fileDescriptor],
                                          kCFSocketNoCallBack, NULL, NULL);
        CFDataRef addrData = CFSocketCopyPeerAddress(socket);
        CFRelease(socket);
        if( addrData ) {
            struct sockaddr_in *sock = (struct sockaddr_in *)CFDataGetBytePtr(addrData);
            char *naddr = inet_ntoa(sock->sin_addr);
            [self setAddress:[NSString stringWithCString:naddr]];
            CFRelease(addrData);
        } else {
            [self setAddress:@"NULL"];
        }

        // Register for notification when data arrives
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(dataReceivedNotification:)
                   name:NSFileHandleReadCompletionNotification
                 object:fileHandle];
        [fileHandle readInBackgroundAndNotify];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if( message ) CFRelease(message);
    [delegate release];
    [fileHandle release];
	[server release];
    [super dealloc];
}

- (NSFileHandle *)fileHandle { return fileHandle; }

- (void)setAddress:(NSString *)value
{
    [address release];
    address = [value copy];
}
- (NSString *)address { return address; }


- (void)dataReceivedNotification:(NSNotification *)notification
{
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    
    if ( [data length] == 0 ) {
        // NSFileHandle's way of telling us that the client closed the connection
        [delegate closeConnection:self];
    } else {
        [fileHandle readInBackgroundAndNotify];
        
        if( isMessageComplete ) {
            message = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
        }
        Boolean success = CFHTTPMessageAppendBytes(message,
                                                   [data bytes],
                                                   [data length]);
        if( success ) {
            if( CFHTTPMessageIsHeaderComplete(message) ) {
                isMessageComplete = YES;
                CFURLRef url = CFHTTPMessageCopyRequestURL(message);
                [delegate newRequestWithURL:(NSURL *)url connection:self];
                CFRelease(url);
                CFRelease(message);
                message = NULL;
            } else {
                isMessageComplete = NO;
            }
        } else {
            NSLog(@"Incomming message not a HTTP header, ignored.");
            [delegate closeConnection:self];
        }
    }
}

// The Content-Length header field will be automatically added
- (void)replyWithStatusCode:(int)code
                    headers:(NSDictionary *)headers
                       body:(NSData *)body
{
    CFHTTPMessageRef msg;
    msg = CFHTTPMessageCreateResponse(kCFAllocatorDefault,
                                      code,
                                      NULL, // Use standard status description 
                                      kCFHTTPVersion1_1);
	
    NSEnumerator *keys = [headers keyEnumerator];
    NSString *key;
    while( key = [keys nextObject] ) {
        id value = [headers objectForKey:key];
        if( ![value isKindOfClass:[NSString class]] ) value = [value description];
        if( ![key isKindOfClass:[NSString class]] ) key = [key description];
        CFHTTPMessageSetHeaderFieldValue(msg, (CFStringRef)key, (CFStringRef)value);
    }
	
    if( body ) {
        NSString *length = [NSString stringWithFormat:@"%d", [body length]];
        CFHTTPMessageSetHeaderFieldValue(msg,
                                         (CFStringRef)@"Content-Length",
                                         (CFStringRef)length);
        CFHTTPMessageSetBody(msg, (CFDataRef)body);
    }
    
    CFDataRef msgData = CFHTTPMessageCopySerializedMessage(msg);
    @try {
        NSFileHandle *remoteFileHandle = [self fileHandle];
        [remoteFileHandle writeData:(NSData *)msgData];
    }
    @catch (NSException *exception) {
        NSLog(@"Error while sending response (%@): %@", [[self currentRequest] objectForKey:@"url"], [exception  reason]);
    }
    
    CFRelease(msgData);
    CFRelease(msg);
	
	[[self server] connectionDidClose:self];
}

- (TCHTTPServer *)server{
	return server;
}

-(void)_setServer:(TCHTTPServer *)srv{
	[srv retain];
	[server release];
	server = srv;
}

-(NSData *)messageBody{
	CFDataRef messageData = CFHTTPMessageCopyBody(message);
	NSData *messageBody = (NSData *)messageData;
	return [messageBody autorelease];
}

@end
