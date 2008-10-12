//
//  TCOrganizationPluginManager.h
//  Technicolor
//
//  Created by Steve Streza on 10/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TCOrganizationPluginManager : NSObject {
	NSMutableArray *mClasses;
	NSMutableArray *mInstances;
}
-(BOOL)classIsValidPlugin:(Class)pluginClass;
-(void)addPluginClass:(Class)pluginClass;
-(void)addPluginInstance:(id)pluginInstance;
@end
