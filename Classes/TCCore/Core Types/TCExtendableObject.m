//
//  TCExtendableObject.m
//  Technicolor
//
//  Created by Steve Streza on 2/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TCExtendableObject.h"


@implementation TCExtendableObject

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context{
	if(self = [super initWithEntity:entity insertIntoManagedObjectContext:context]){
		[self _setupPropertyDictionary];
	}
	return self;
}

-(void)_setupPropertyDictionary{
	if(props) return;
	
	NSData *data = [self valueForKey:@"extraProperties"];
	
	if(data){
		NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		NSLog(@"Whee! %@",dict);
	}
	
	props = [[NSMutableDictionary alloc] init];	
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
	NSLog(@"-[TCExtendableObject setValue: %@ forUndefinedKey: %@]",value,key);
	[self _setupPropertyDictionary];
	[props setObject:value forKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key{
	NSLog(@"-[TCExtendableObject valueForUndefinedKey: %@],key");
	return [props valueForKey:key];
}

- (BOOL)validateValue:(id *)value forKey:(NSString *)key error:(NSError **)error{
	*error = nil;
	
	NSLog(@"Validating %@ with %@",key,*value);
	if([key isEqualToString:@"extraProperties"] && props){
		*value = [NSKeyedArchiver archivedDataWithRootObject:props];
		NSLog(@"Archived - %@",*value);
		return YES;
	}
	return YES;
}

@end
