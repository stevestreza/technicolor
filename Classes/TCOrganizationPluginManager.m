/*
 
 Copyright (c) 2008 Technicolor Project
 Licensed under the MIT License
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "TCOrganizationPluginManager.h"
#import "Technicolor_AppDelegate.h"
#import "TCCore.h"
#import "TCOrganizationPlugin.h"
#import <CoreFoundation/CoreFoundation.h>

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
		if([self loadAllDependenciesForBundle:bundle]){
			[self _addClass:pluginClass];
			[self _addBundle:bundle];
		
			id pluginInstance = [[pluginClass alloc] init];
		
			CFUUIDRef uuid = [(TCOrganizationPlugin *)pluginInstance uuid];
		
			[self addPluginInstance:pluginInstance];
			[pluginInstance release];
		}
	}	
}

-(BOOL)loadAllDependenciesForBundle:(NSBundle *)bundle{
	NSArray *uuids = [[bundle infoDictionary] valueForKey:@"dependencies"];
	return YES;
}

-(NSMutableDictionary *)_uuidDictionary{
	if(!mUUIDDictionary){
		mUUIDDictionary = [[NSMutableDictionary alloc] init];
	}
	return mUUIDDictionary;
}

-(void)addPluginInstance:(id)pluginInstance{
	if(pluginInstance){
		[self _addInstance:pluginInstance];
		[pluginInstance awake];
	}
}
			
-(BOOL)classIsValidPlugin:(Class)pluginClass{
	return YES;
	return [pluginClass isSubclassOfClass:[TCOrganizationPlugin class]];
}

-(NSArray *)allBundles{
	NSArray *paths = [NSArray arrayWithObjects:
						[[(Technicolor_AppDelegate *)[NSApp delegate] applicationSupportFolder] stringByAppendingPathComponent:@"Plugins"],
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

-(NSBundle *)bundleForUUID:(NSString *)uuid{
	
}

@end
