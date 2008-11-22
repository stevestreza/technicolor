//
//  XMLRPCServer.m
//  Technicolor
//
//  Created by Steve Streza on 11/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "XMLRPCServer.h"
#import "XMLRPCResponse.h"

@interface XMLRPCInvocation : NSInvocation {
	NSString *methodName;
	
	id realTarget;
	SEL realSelector;
}

@end

@implementation XMLRPCInvocation

+(XMLRPCInvocation *)invocationWithMethodName:(NSString *)methodName
									   target:(id)target
									 selector:(SEL)selector{
	XMLRPCInvocation *invocation = [XMLRPCInvocation invocationWithMethodSignature:[target methodSignatureForSelector:selector]];
	[invocation _setTarget:target selector:selector];
	return [[invocation retain] autorelease];
}

-(void)_setTarget:(id)newTarget selector:(SEL)newSelector{
	realTarget = newTarget;
	realSelector = newSelector;

	[self setTarget:newTarget];
	[self setSelector:newSelector];
}

-(NSString *)methodName{
	return methodName;
}

- (id)copyWithZone:(NSZone *)zone{
//	XMLRPCInvocation *obj = [[XMLRPCInvocation allocWithZone:zone] init];
	return [XMLRPCInvocation invocationWithMethodName:methodName target:realTarget selector:realSelector];
}

@end

@interface NSInvocationOperation (Convenience)
+(NSInvocationOperation *)operationForInvocation:(NSInvocation *)inv;
@end

@implementation NSInvocationOperation (Convenience)

+(NSInvocationOperation *)operationForInvocation:(NSInvocation *)inv{
	return [[[NSInvocationOperation alloc] initWithInvocation:inv] autorelease];
}

@end


@interface XMLRPCServer (XMLRPCInvocation)
-(XMLRPCInvocation *)findInvocationForMethod:(NSString *)methodSelector;
@end

@implementation XMLRPCServer

- (id)initWithTCPPort:(unsigned)po{
	if(self = [super initWithTCPPort:po delegate:self]){
		methodDictionary = [[NSMutableDictionary alloc] init];
		
		handlerQueue = [[NSOperationQueue alloc] init];
	}
	return self;
}

-(NSMutableDictionary *)addNamespaceNamed:(NSString *)namespacePath{
	return [self namespaceForPath:namespacePath createIfNecessary:YES];
}

-(void)addMethodNamed:(NSString *)methodName 
			forTarget:(id)target
			 selector:(SEL)selector{
	[methodDictionary setValue:[XMLRPCInvocation invocationWithMethodName:methodName target:target selector:selector]
						forKey:methodName];
}

- (void)processURL:(NSURL *)path connection:(SimpleHTTPConnection *)connection{
	NSLog(@"Path: %@",path);

	NSData *data = [connection messageBody];
	NSString *dataBody = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	
	NSError *err = nil;
	NSXMLDocument *document = [[[NSXMLDocument alloc] initWithData:data options:0 error:&err] autorelease];
	if(document && !err){
		NSString *methodName = [self methodNameForXMLDocument:document error:&err];
		XMLRPCInvocation *inv = [[self findInvocationForMethod:methodName] copy];
		
		[inv setArgument:&connection atIndex:2];		
		[handlerQueue addOperation:[NSInvocationOperation operationForInvocation:inv]]; 
		return;
	}
	[connection replyWithStatusCode:404 headers:nil body:nil];
}

-(XMLRPCInvocation *)findInvocationForMethod:(NSString *)methodSelector{
	id value = nil;
	if(value = [methodDictionary valueForKey:methodSelector]){
		goto METHOD_FOUND;
	}
	
	NSDictionary *currentNamespace = [self namespaceForPath:methodSelector createIfNecessary:NO];
	if(currentNamespace){
		value = [currentNamespace valueForKey:[[methodSelector componentsSeparatedByString:@"."] lastObject]];
	}
	
METHOD_FOUND:
	
	if( value == nil || ![value isKindOfClass:[XMLRPCInvocation class]]) {
		value =  nil;
	}
	
	return value;
}

-(NSDictionary *)namespaceForPath:(NSString *)namespacePath createIfNecessary:(BOOL)createIfNecessary{
	NSMutableDictionary *currentNamespace = methodDictionary;
	NSArray *pieces = [namespacePath componentsSeparatedByString:@"."];
	NSUInteger pieceIndex = 0;
	for(pieceIndex = 0; pieceIndex < pieces.count - 1; pieceIndex++){
		NSString *namespace = [pieces objectAtIndex:pieceIndex];
		currentNamespace = [currentNamespace valueForKey:namespace];
		
		if(!currentNamespace){
			if(createIfNecessary){
				id newDict = [NSMutableDictionary dictionary];
				[currentNamespace setValue:newDict forKey:namespace];
				currentNamespace = newDict;
			}else{
				return nil;
			}
		}
	}
	return currentNamespace;
}

-(NSString *)methodNameForXMLDocument:(NSXMLDocument *)document error:(NSError **)err{
	NSArray *nameNodes = [document nodesForXPath:@"/methodCall/methodName" error:&err];
	if(nameNodes && nameNodes.count > 0){
		NSString *methodName = [(NSXMLNode *)[nameNodes objectAtIndex:0] stringValue];
		return methodName;
	}
	return nil;
}

- (void)stopProcessing{
	
}

@end
