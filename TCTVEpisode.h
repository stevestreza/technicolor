//
//  TCTVEpisode.h
//  Technicolor
//
//  Created by Steve Streza on 8/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TCVideo.h"
@class TCTVShow;

#import "TCCalendar.h"
#import "TCCalendarEvent.h"

@interface TCTVEpisode : NSManagedObject {

}

+(TCTVEpisode *)showVideoWithEpisodeName:(NSString *)name season:(int)season episodeNumber:(int)episode show:(TCTVShow *)show;

+(NSPredicate *)predicateForEpisodesOnToday;
+(NSPredicate *)predicateForFavoriteShowsOnToday;
+(NSPredicate *)predicateForNonfavoriteShowsOnToday;

+(NSArray *)episodesOnToday;
@end
