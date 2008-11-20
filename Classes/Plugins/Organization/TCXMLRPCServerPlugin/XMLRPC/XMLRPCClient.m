//
//  XMLRPCClient.m
//  NZBTap
//
//  Created by Steve Streza on 9/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "XMLRPCClient.h"

@interface XMLRPCClient (TNSWPrivate)

-(void)_setHost:(NSString *)newHost
		   port:(UInt16)    newPort
	   userName:(NSString *)newUsername
	   password:(NSString *)newPassword;

@end

@implementation XMLRPCClient

@synthesize host, port, userName, password;

-(id)initWithDictionary:(NSDictionary *)dict{
	return [self initWithHost:[dict valueForKey:@"host"]
						 port:(UInt16)[[dict valueForKey:@"port"] unsignedIntValue]
					 userName:[dict valueForKey:@"userName"] 
					 password:[dict valueForKey:@"password"]];
}

-(id)initWithHost:(NSString *)newHost port:(UInt16)newPort userName:(NSString *)newUserName password:(NSString *)newPassword{
	if(self = [super init]){
		[self _setHost:newHost
				  port:newPort
			  userName:newUserName
			  password:newPassword];
		
		[self awake];
	}
	return self;
}

-(void)awake{
	[self getMethods];
}

-(void)_setHost:(NSString *)newHost
		   port:(UInt16)    newPort
	   userName:(NSString *)newUsername
	   password:(NSString *)newPassword{
	host = [newHost copy];
	port = newPort;
	userName = [newUsername copy];
	password = [newPassword copy];
}


-(NSString *)baseURLString{
	return [NSString stringWithFormat:@"http://%@:%@@%@:%i/",userName, password, host, port];
}

-(XMLRPCRequest *)createRequest{
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:[NSURL URLWithString:[self baseURLString]]];
	return [request autorelease];
}

-(void)callMethod:(NSString *)methodName withObjects:(NSArray *)objects{
	if(objects && ![objects isKindOfClass:[NSArray class]]){
		objects = [NSArray arrayWithObject:objects];
	}
	
	XMLRPCRequest *request = [self createRequest];
	[request setMethod:methodName withObjects:objects];
	
	XMLRPCConnection *connection = [[XMLRPCConnection alloc] initWithXMLRPCRequest:request delegate:self];
}

-(void)getMethods{
	[self callMethod:XMLRPCGetMethodsName withObjects:nil];
}

-(void)getSignatureForMethod:(NSString *)methodName{
	[self callMethod:XMLRPCMethodSignatureName withObjects:methodName];
}

-(void)getHelpForMethod:(NSString *)methodName{
	[self callMethod:XMLRPCMethodHelpName withObjects:methodName];	
}

-(void)handleGetMethods:(XMLRPCResponse *)response withRequest:(XMLRPCRequest *)request error:(NSError *)error{
	if(error){
//		NSLog(@"ListMethods error: %@",error);
	}else{
//		NSLog(@"listMethods response: %@",response);
		NSArray *methodArray = (NSArray *)[response object];
		if(![methodArray isKindOfClass:[NSArray class]]) return;
		methods = [NSMutableDictionary dictionaryWithCapacity:[methodArray count]];
		
		UInt32 index =0;
		for(index; index < [methodArray count]; index++){
			NSString *methodName = [methodArray objectAtIndex:index];
			if(![methods valueForKey:methodName]){
//				NSLog(@"Adding method %@",methodName);
				[methods setValue:@"" forKey:methodName];
			
//				[self getSignatureForMethod:methodName];
//				[self getHelpForMethod:methodName];
			}
		}
//		NSLog(@"Methods: %@",methods);
		[methods retain];
	}
}



-(void)handleMethodsSignature:(XMLRPCResponse *)response withRequest:(XMLRPCRequest *)request error:(NSError *)error{
	if(error){
//		NSLog(@"MethodsSignature error: %@",error);
	}else{
//		NSLog(@"methodsSignature response: %@",response);
		NSString *key = [[request objects] objectAtIndex:0];
		NSMutableDictionary *methodDict = [methods valueForKey:key];
		if(!methodDict || [methodDict isKindOfClass:[NSString class]]){
			methodDict = [NSMutableDictionary dictionary];
			[methods setValue:methodDict forKey:key];
		}
		
		[methodDict setValue:[response object] forKey:XMLRPCMethodSignatureName];		
//		NSLog(@"%@",methods);
	}
}



-(void)handleMethodsHelp:(XMLRPCResponse *)response withRequest:(XMLRPCRequest *)request error:(NSError *)error{
	if(error){
//		NSLog(@"MethodsHelp error: %@",error);
	}else{
//		NSLog(@"methodsHelp response: %@",response);
		
		NSString *key = [[request objects] objectAtIndex:0];
		NSMutableDictionary *methodDict = [methods valueForKey:key];
		if(!methodDict || [methodDict isKindOfClass:[NSString class]]){
			methodDict = [NSMutableDictionary dictionary];
			[methods setValue:methodDict forKey:key];
		}
		
		[methodDict setValue:[response object] forKey:XMLRPCMethodHelpName];
		
//		NSLog(@"%@",methods);
	}
}

-(void)handleMethod:(NSString *)methodName 
	   withResponse:(XMLRPCResponse *)response 
			request:(XMLRPCRequest *)request 
			  error:(NSError *)error{
#define IsConnection(__nm) [methodName isEqualToString:__nm]
	if(IsConnection(XMLRPCGetMethodsName)){
		[self handleGetMethods:response withRequest:request error:error];
	}else if(IsConnection(XMLRPCMethodSignatureName)){
		[self handleMethodsSignature:response withRequest:request error:error];
	}else if(IsConnection(XMLRPCMethodHelpName)){
		[self handleMethodsHelp:response withRequest:request error:error];
	}else{
		NSString *selectorName = [NSString stringWithFormat:@"handle%@%@:withRequest:error:",
									   [[methodName substringWithRange:NSMakeRange(0,1)] uppercaseString],
										[methodName substringWithRange:NSMakeRange(1,[methodName length]-1)]];
		
		SEL selector = NSSelectorFromString(selectorName);
		if([self respondsToSelector:selector]){
			if(!response) response = [NSNull null];
			if(!request ) request  = [NSNull null];
			if(!error   ) error    = [NSNull null];
			@try {
				NSArray *selectorParts = [selectorName componentsSeparatedByString:@":"];
//				NSLog(@"Calling -[self %@:%@ %@:%@ %@:%@];",
//					  [selectorParts objectAtIndex:0], response,
//					  [selectorParts objectAtIndex:1], request,
//					  [selectorParts objectAtIndex:2], error);
				
				NSMethodSignature *sig = [self methodSignatureForSelector:selector];
				NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
				[inv setArgument:&response atIndex:2];
				[inv setArgument:&request  atIndex:3];
				[inv setArgument:&error    atIndex:4];
				[inv setSelector:selector];
				
				[inv invokeWithTarget:self];
				
//				NSLog(@"Calling finished");
			}
			@catch (NSException * e) {
				NSLog(@"Exception for %@ %@",methodName,e);
			}
		}
	}
#undef IsConnection
}

- (void)connection: (XMLRPCConnection *)connection didReceiveResponse: (XMLRPCResponse *)response
		 forMethod: (NSString *)method{
	[self handleMethod:method withResponse:response request:[connection request] error:nil];
}

- (void)connection: (XMLRPCConnection *)connection didFailWithError: (NSError *)error
		 forMethod: (NSString *)method{
	[self handleMethod:method withResponse:nil request:[connection request] error:error];
}

-(NSDictionary *)dictionary{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			host, @"host",
			[NSNumber numberWithInt:port], @"port",
			userName, @"userName",
			password, @"password",
			nil];
}

@end
