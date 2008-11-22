//
//  TCHTTPHandler.m
//  Technicolor
//
//  Created by Steve Streza on 11/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCHTTPHandler.h"


@implementation TCHTTPHandler

@synthesize regex=mRegex, connection=mConnection;

-(id)initWithRegex:(NSString *)regex
			target:(id)target
		  selector:(SEL)selector{

	if(self = [super init]){
		[self _setRegex:regex];
		[self _setTarget:target selector:selector];
		
		return self;
	}
	
	[self release];
	self = nil;
	
	return self;
}

-(id)copyWithZone:(NSZone *)zone{
	TCHTTPHandler *handler = [[TCHTTPHandler allocWithZone:zone] initWithRegex:mRegex 
																		target:mTarget
																	  selector:mSelector];
	return handler;
}

-(void)_setTarget:(id)target selector:(SEL)selector{
	mTarget   = target;
	mSelector = selector;
}

-(void)_setRegex:(NSString *)regex{
	[mRegex autorelease];
	mRegex = [regex copy];
}

-(NSMethodSignature *)methodSignature{
	return [mTarget methodSignatureForSelector:mSelector];
}

-(NSInvocation *)invocation{
	NSMethodSignature *sig = [self methodSignature];
	if(sig){
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
		[invocation setArgument:&mConnection atIndex:2];

		[invocation setTarget:mTarget];
		[invocation setSelector:mSelector];
		
		return invocation;
	}
	return nil;
}

-(void)main{
	//handler type: handleRequest:
	[[self invocation] invoke];
}

@end
