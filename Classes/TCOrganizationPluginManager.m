//
//  TCOrganizationPluginManager.m
//  Technicolor
//
//  Created by Steve Streza on 10/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCOrganizationPluginManager.h"
#import "Technicolor_AppDelegate.h"
#import "TCCore.h"
#import "TCOrganizationPlugin.h"

@interface TCOrganizationPluginManager (Private)
-(void)_addClass:(Class)pluginClass;
-(void)_addInstance:(id)pluginInstance;
-(void)_addBundle:(NSBundle *)pluginBundle;
@end

@implementation TCOrganizationPluginManager

@synthesize pluginModel=mPluginModel;

-(void)loadPlugins{
	NSArray *bundles = [self allBundles];
	NSMutableArray *models = [NSMutableArray arrayWithCapacity:bundles.count+1];
	[models addObject:[TCCore coreModel]];
	
	for(NSBundle *pluginBundle in bundles){
		Class principleClass = [pluginBundle principalClass];
		[self addPluginClass:principleClass forBundle:pluginBundle];
		
		NSManagedObjectModel *model = [principleClass objectModel];
		if(model){
			[models addObject:model];
		}
	}
	
	NSManagedObjectModel *masterModel = [NSManagedObjectModel modelByMergingModels:models];
	NSLog(@"Plugins loaded");
	
	mPluginModel = [masterModel retain];
}

-(void)_addClass:(Class)pluginClass{
	if(!mClasses){
		mClasses = [[NSMutableArray array] retain];
	}
	[mClasses addObject:[NSValue valueWithPointer:(void *)pluginClass]];
}

-(void)_addInstance:(id)pluginInstance{
	if(!mInstances){
		mInstances = [[NSMutableArray array] retain];
	}
	
	[mInstances addObject:pluginInstance];	
}

-(void)_addBundle:(NSBundle *)pluginBundle{
	if(!mBundles){
		mBundles = [[NSMutableArray array] retain];
	}
	
	[mBundles addObject:pluginBundle];
}


-(void)addPluginClass:(Class)pluginClass forBundle:(NSBundle *)bundle{
	if(pluginClass && [self classIsValidPlugin:pluginClass]){
		[self _addClass:pluginClass];
		[self _addBundle:bundle];
		
		id pluginInstance = [[pluginClass alloc] init];
		[self addPluginInstance:pluginInstance];
		[pluginInstance release];
	}	
}

-(void)addPluginInstance:(id)pluginInstance{
	if(pluginInstance){
		[self _addInstance:pluginInstance];
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
