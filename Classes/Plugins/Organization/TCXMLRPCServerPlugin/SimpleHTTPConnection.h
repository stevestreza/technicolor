//
//  SimpleHTTPConnection.h
//  SimpleCocoaHTTPServer
//
//  Created by Jürgen Schweizer on 13.09.06.
//  Copyright 2006 Cultured Code.
//  License: Creative Commons Attribution 2.5 License
//           http://creativecommons.org/licenses/by/2.5/
//

#import <Cocoa/Cocoa.h>
#import "SimpleHTTPServer.h"

@interface SimpleHTTPConnection : NSObject {
	SimpleHTTPServer *server;
	
    NSFileHandle *fileHandle;
    id delegate;
    NSString *address;  // client IP address

    CFHTTPMessageRef message;
    BOOL isMessageComplete;
}

- (id)initWithFileHandle:(NSFileHandle *)fh delegate:(id)dl;
- (NSFileHandle *)fileHandle;
- (SimpleHTTPServer *)server;

- (void)setAddress:(NSString *)value;
- (NSString *)address;

-(NSData *)messageBody;
@end
