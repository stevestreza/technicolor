//
//  TVRageController.h
//  Technicolor
//
//  Created by Steve Streza on 8/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TCTVRageImports.h"
#import "TVRageOperation.h"

@interface TVRageController : NSObject {

}

+ (TVRageController*)sharedController;
-(void)beginLoadOperation:(TCTVRageOperationType)operationType withInfoObject:(id)infoObject delegate:(id)delegate;

-(void)loadCurrentDayScheduleWithDelegate:(id)delegate;

@end
