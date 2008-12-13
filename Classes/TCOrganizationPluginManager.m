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
#import "TCCoreUtils.h"
#import "TCOrganizationPlugin.h"
#import <CoreFoundation/CoreFoundation.h>

@interface NSMutableArray (StackOperations)
-(void)push:(id)obj;
-(id)pop;
@end

@implementation NSMutableArray (StackOperations)
-(void)push:(id)obj{
	[self addObject:obj];
}

-(id)pop{
	if(self.count == 0) return nil;
	
	id firstObject = [[[self objectAtIndex:0] retain] autorelease];
	[self removeObjectAtIndex:0];
	return firstObject;
}

@end

@interface TCOrganizationPluginManager (Private)
-(void)_addClass:(Class)pluginClass;
-(void)_addInstance:(id)pluginInstance;
-(void)_addBundle:(NSBundle *)pluginBundle;
@end

@implementation TCOrganizationPluginManager

@synthesize pluginModel=mPluginModel;

-(void)loadPlugins{
	NSArray *bundles = [self allBundlesWithDependencies];
	NSMutableArray *models = [NSMutableArray arrayWithCapacity:bundles.count+1];
	[models addObject:[TCCoreUtils coreModel]];
	
	for(NSBundle *pluginBundle in bundles){
		Class principleClass = [pluginBundle principalClass];
		[self addPluginClass:principleClass forBundle:pluginBundle];
		
		NSManagedObjectModel *model = [principleClass objectModel];
		if(model){
			[models addObject:model];
		}
	}
	
	NSManagedObjectModel *masterModel = [NSManagedObjectModel modelByMergingModels:models];
//	NSLog(@"Plugins loaded");
	
	mPluginModel = [masterModel retain];
	
	[self initializeAllPlugins];
}

-(void)initializeAllPlugins{
	for(NSValue *classPtr in mClasses){
		Class pluginClass = (Class)([classPtr pointerValue]);
		
		id pluginInstance = [[pluginClass alloc] init];
		
		CFUUIDRef uuid = [(TCOrganizationPlugin *)pluginInstance uuid];
		
		[self addPluginInstance:pluginInstance];
		[pluginInstance release];		
	}
	[self awakeAllInstances];
}

-(void)awakeAllInstances{
	NSMutableArray *instanceStack = [NSMutableArray arrayWithCapacity:mInstances.count];
	NSMutableDictionary *uuidsActivated = [NSMutableDictionary dictionaryWithCapacity:mInstances.count];
	
	for(TCOrganizationPlugin *pluginInstance in mInstances){
		[instanceStack push:pluginInstance];
	}
	
	printf("");
	
	while(instanceStack.count > 0){
		BOOL shouldAwake = YES;
		
		TCOrganizationPlugin *plugin = [instanceStack pop];
		NSString *uuid = [plugin uuidString];
		
		if([uuidsActivated valueForKey:uuid]){
			shouldAwake = NO;
			continue;
		}
		
		NSBundle *bundle = [self bundleForUUID:uuid];
		NSArray *dependencies = [[bundle infoDictionary] valueForKey:@"Dependencies"];
		if(dependencies && dependencies.count > 0){
//			NSLog(@"Dependencies for %@ - %@",uuid,dependencies);
			BOOL needsRepush = NO;
			for(NSString *depUUID in dependencies){
//				NSLog(@"Pushing depID %@",depUUID);
				if(![uuidsActivated valueForKey:depUUID]){
					needsRepush = YES;
					shouldAwake = NO;
					[instanceStack push:[self pluginWithUUID:depUUID]];
				}
			}
			if(needsRepush){
				[instanceStack push:plugin];
				continue;
			}
		}
		
		if(shouldAwake){
		
		[uuidsActivated setValue:kCFBooleanTrue forKey:uuid];
//		NSLog(@"Awaking %@",[plugin className]);
		[plugin awake];
		}
		
	}
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
	
	if(!mPluginsByUUID){
		mPluginsByUUID = [[NSMutableDictionary dictionary] retain];
	}
	[mPluginsByUUID setValue:pluginInstance forKey:[pluginInstance uuidString]];
}

-(TCOrganizationPlugin *)pluginWithUUID:(NSString *)uuid{
	return [mPluginsByUUID valueForKey:uuid];
}

-(void)_addBundle:(NSBundle *)pluginBundle{
	if(!mBundles){
		mBundles = [[NSMutableArray array] retain];
	}
	
	[mBundles addObject:pluginBundle];
}


-(void)addPluginClass:(Class)pluginClass forBundle:(NSBundle *)bundle{
	if(pluginClass && [self classIsValidPlugin:pluginClass]){
//		if([self loadAllDependenciesForBundle:bundle]){
			[self _addClass:pluginClass];
			[self _addBundle:bundle];
//		}
	}	
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
	}
}
			
-(BOOL)classIsValidPlugin:(Class)pluginClass{
	return YES;
	return [pluginClass isSubclassOfClass:[TCOrganizationPlugin class]];
}

-(NSArray *)allBundles{
	[self reloadBundles];
	
	return [[self _uuidDictionary] allValues];
}

-(NSArray *)allBundlesWithDependencies{
	NSArray *sourceBundles = [self allBundles];
	NSMutableArray *bundleUUIDStack = [NSMutableArray arrayWithCapacity:sourceBundles.count];
	NSMutableDictionary *allBundles = [NSMutableDictionary dictionary];
	
	for(NSBundle *bundle in sourceBundles){
		[bundleUUIDStack push:[[bundle infoDictionary] valueForKey:@"UUID"]];
	}

//	NSLog(@"------\nFetching dependencies for: %@\n-",bundleUUIDStack);
	
	while(bundleUUIDStack.count > 0){
		NSString *uuid = [bundleUUIDStack pop];
		
//		NSLog(@"\n--%i UUIDs left - %@",(bundleUUIDStack.count+1),uuid);
		
		if([allBundles valueForKey:uuid]){
			continue;
		}
		
		NSBundle *bundle = [[self _uuidDictionary] valueForKey:uuid];
		[allBundles setValue:bundle forKey:uuid];
		
		NSArray *deps = [[bundle infoDictionary] valueForKey:@"Dependencies"];
		for(NSString *depUUID in deps){
			if(![allBundles valueForKey:depUUID]){
//				NSLog(@"Dependency found: %@ needs %@",uuid, depUUID);
				[bundleUUIDStack push:depUUID];
			}
		}
	}

//	NSLog(@"------\Finished deps: %@\n-",[allBundles allKeys]);
	
	return [[[allBundles allValues] copy] autorelease];
}

-(void)reloadBundles{
	if(mUUIDDictionary) return;
	
	mUUIDDictionary = [[NSMutableDictionary alloc] init];
	
	NSArray *paths = [NSArray arrayWithObjects:
					  [[(Technicolor_AppDelegate *)[NSApp delegate] applicationSupportFolder] stringByAppendingPathComponent:@"Plugins"],
					  [@"~/Projects/Technicolor/technicolor/build/Debug/" stringByExpandingTildeInPath],
					  nil];
	
	NSMutableArray *bundles = [NSMutableArray array];
	
	for(NSString *path in paths){
		NSArray *bundleNames = [[NSFileManager defaultManager] directoryContentsAtPath:path];
		for(NSString *bundleName in bundleNames){
			if([[bundleName pathExtension] isEqualToString:@"tcplugin"]){
				NSString *fullPath = [path stringByAppendingPathComponent:bundleName];
				NSBundle *bundle = [NSBundle bundleWithPath:fullPath];
				if(bundle){
					NSDictionary *bundleInfo = [bundle infoDictionary];
					
					NSString *uuid = [bundleInfo valueForKey:@"UUID"];
					if(!uuid){
//						NSLog(@"ERROR - Could not find UUID for %@",path);
					}else{
						[mUUIDDictionary setValue:bundle forKey:uuid];
					
						[bundles addObject:bundle];
					}
				}
			}
		}
	}
	
	return [[bundles copy] autorelease];
}

-(NSBundle *)bundleForUUID:(NSString *)uuid{
	return [[self _uuidDictionary] valueForKey:uuid];
}

static TCOrganizationPluginManager * sSharedPluginManager = ((void *)0); 

+ ( TCOrganizationPluginManager * ) sharedPluginManager {
	@synchronized(self) {
		if ( sSharedPluginManager == nil) {
			[[self alloc] init];
		}
	} 
	return sSharedPluginManager;
} 

+ (id)allocWithZone:(NSZone *)zone{
	@synchronized(self){
		if( sSharedPluginManager == nil) { 
			sSharedPluginManager = [super allocWithZone:zone]; 
			return sSharedPluginManager ;
		}
	} 
	return nil;
}

- (id)copyWithZone:(NSZone *)zone{return self;}
- (id)retain{return self;}
- (unsigned)retainCount{return UINT_MAX;}
- (void)release{}
- (id)autorelease{return self;}

@end
