//
//  TCDVDVideo.m
//  Technicolor
//
//  Created by Steve Streza on 8/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCDVDVideo.h"
#import "hb.h"

@implementation TCDVDVideo

static hb_handle_t *sHBHandle = NULL;

+(void)initialize{
	setenv("HB_DEBUG","true",1);
}

-(void)loadTitles{
	if(!sHBHandle){
		sHBHandle = hb_init_dl(HB_DEBUG_ALL, 0);
	}
	
	char *path = [[[self path] stringByDeletingLastPathComponent] UTF8String];
	
	hb_scan(sHBHandle,path,0);
}

@end
