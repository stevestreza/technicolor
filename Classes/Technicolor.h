/*
 *  Technicolor.h
 *  Technicolor
 *
 *  Created by Steve Streza on 10/19/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#define TCUUID(__uuid) static CFUUIDRef sUUID = NULL; \
-(CFUUIDRef)uuid{ \
	if(!sUUID){ \
		sUUID = CFUUIDCreateFromString(NULL, ((CFStringRef)(__uuid)) ); \
	} \
	return sUUID; \
} \
