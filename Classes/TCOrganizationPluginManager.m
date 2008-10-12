//
//  TCOrganizationPluginManager.m
//  Technicolor
//
//  Created by Steve Streza on 10/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCOrganizationPluginManager.h"
#import "Technicolor_AppDelegate.h"

#import "TCOrganizationPlugin.h"

@implementation TCOrganizationPluginManager

-(void)loadPlugins{
	NSArray *bundles = [self allBundles];

	for(NSBundle *pluginBundle in bundles){
		Class principleClass = [pluginBundle principalClass];
		[self addPluginClass:principleClass];
	}
}

-(void)addPluginClass:(Class)pluginClass{
	if(pluginClass && [self classIsValidPlugin:pluginClass]){
		if(!mClasses){
			mClasses = [[NSMutableArray array] retain];
		}
		[mClasses addObject:[NSValue valueWithPointer:(void *)pluginClass]];
		
		id pluginInstance = [[pluginClass alloc] init];
		[self addPluginInstance:pluginInstance];
		[pluginInstance release];
	}	
}

-(void)addPluginInstance:(id)pluginInstance{
	if(pluginInstance){
		if(!mInstances){
			mInstances = [[NSMutableArray array] retain];
		}
		
		[mInstances addObject:pluginInstance];
		
		[pluginInstance awake];
	}
}
			
-(BOOL)classIsValidPlugin:(Class)pluginClass{
	return [pluginClass isSubclassOfClass:[TCOrganizationPlugin class]];
}

-(NSArray *)allBundles{
	NSArray *paths = [NSArray arrayWithObjects:
						[(Technicolor_AppDelegate *)[NSApp delegate] applicationSupportFolder],
						[@"~/Projects/Technicolor/build/Debug/" stringByExpandingTildeInPath],
					  nil];

	NSMutableArray *bundles = [NSMutableArray array];
	
	for(NSString *path in paths){
		NSArray *bundleNames = [[NSFileManager defaultManager] directoryContentsAtPath:path];
		for(NSString *bundleName in bundleNames){
			if([[bundleName pathExtension] isEqualToString:@"tcplugin"]){
				NSString *fullPath = [path stringByAppendingPathComponent:bundleName];
				NSBundle *bundle = [NSBundle bundleWithPath:fullPath];
				if(bundle){
					[bundles addObject:bundle];
				}
			}
		}
	}
	
	return [[bundles copy] autorelease];
}

@end
