//
//  TCXMLRPCTVEpisodeHandler.m
//  Technicolor
//
//  Created by Steve Streza on 11/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCXMLRPCTVEpisodeHandler.h"


@implementation TCXMLRPCTVEpisodeHandler

-(NSArray *)methodNames{
	return [NSArray arrayWithObjects:
			@"get",
			nil];
}

-(SEL)selectorForMethodNamed:(NSString *)methodName{
	if([methodName isEqualToString:@"get"]){
		return @selector(getShows:);
	}
}

-(NSString *)name{
	return @"episodes";
}

-(void)getShows:(id)wtf{
	NSLog(@"WTF: %@",wtf);
}

@end
