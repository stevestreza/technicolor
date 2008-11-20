//
//  XMLRPCClient.h
//  NZBTap
//
//  Created by Steve Streza on 9/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define XMLRPCGetMethodsName      @"system.listMethods"
#define XMLRPCMethodSignatureName @"system.methodSignature"
#define XMLRPCMethodHelpName      @"system.methodHelp"


@class XMLRPCRequest, XMLRPCConnection, XMLRPCResponse;

@interface XMLRPCClient : NSObject {
	NSString *host;
	UInt16 port;
	
	NSString *userName;
	NSString *password;
	
	NSDictionary *methods;
}

@property (readonly) NSString *host;
@property (readonly) UInt16 port;
@property (readonly) NSString *userName;
@property (readonly) NSString *password;


-(void)getMethods;
-(id)initWithHost:(NSString *)newHost port:(UInt16)newPort userName:(NSString *)newUserName password:(NSString *)newPassword;
-(void)handleMethod:(NSString *)methodName 
	   withResponse:(XMLRPCResponse *)response 
		withRequest:(XMLRPCRequest *)request 
			  error:(NSError *)error;

-(NSDictionary *)dictionary;
@end
