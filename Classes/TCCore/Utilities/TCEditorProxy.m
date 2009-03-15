//
//  TCEditorProxy.m
//  Technicolor
//
//  Created by Steve Streza on 2/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TCEditorProxy.h"


@implementation TCEditorProxy

+(TCEditorProxy *)proxyForObject:(id)object{
	return [[[TCEditorProxy alloc] initByProxyingObject:object] autorelease];
}

-(void)saveChangesToProxiedObject{
	for(id something in mKeyChanges){
		NSLog(@"Something! %@", something);
	}
}

#pragma mark Internals

-(id)initByProxyingObject:(id)object{
	if(self = [super init]){
		mObject = object;
		
		mKeyChanges = [[NSMutableDictionary alloc] init];
		mKeyPathChanges = [[NSMutableDictionary alloc] init];
		mUndefKeyChanges = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void)dealloc{
	[mKeyChanges release];
	[mKeyPathChanges release];
	[mUndefKeyChanges release];
	
	[super dealloc];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
	
}

- (void)setValue:(id)value forKey:(NSString *)key{
	[mKeyChanges setValue:value forKey:key];
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath{
	[mKeyPathChanges setValue:value forKey:keyPath];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
	[mUndefKeyChanges setValue:value forKey:key];
}

- (id)valueForKey:(NSString *)key{
	id value = [mKeyChanges valueForKey:key];

	if(!value){
		value = [mObject valueForKey:key];
	}
	
	return value;
}

- (id)valueForKeyPath:(NSString *)keyPath{
	id value = [mKeyPathChanges valueForKey:keyPath];
	
	if(!value){
		value = [mObject valueForKeyPath:keyPath];
	}
	
	return value;	
}

- (id)valueForUndefinedKey:(NSString *)key{
	id value = [mUndefKeyChanges valueForKey:key];
	
	if(!value){
		value = [mObject valueForUndefinedKey:key];
	}
	
	return value;	
}

@end
