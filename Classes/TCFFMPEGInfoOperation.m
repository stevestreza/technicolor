//
//  TCFFMPEGInfoOperation.m
//  Technicolor
//
//  Created by Steve Streza on 8/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TCFFMPEGInfoOperation.h"


@implementation TCFFMPEGInfoOperation

static BOOL isInitted = NO;

-(id)initWithVideo:(TCFFMPEGVideo *)ffmpegVideo{
	if(self = [super init]){
		video = [ffmpegVideo retain];
		
		if(!isInitted){
			isInitted = YES;
			av_register_all();
		}
	}
	return self;
}

-(void)main{
//	NSLog(@"Beginning info operation %@",[video path]);
	
	AVFormatContext *pFormatCtx = nil;
	av_open_input_file(&pFormatCtx, [[video path] cStringUsingEncoding:NSASCIIStringEncoding],NULL,0,NULL);
//	NSLog(@"file opened");
	if(pFormatCtx){
//		NSLog(@"We has context!");
		AVInputFormat *inputFormat = (*pFormatCtx).iformat;
//		NSLog(@"Input format get");
		NSString *name = [[NSString alloc] initWithCString:(*inputFormat).name];
//		NSLog(@"File %@ is %@",[video path],name);
		
		NSUInteger width = 0, height = 0;
		NSUInteger i;
		for(i=0; i<pFormatCtx->nb_streams; i++){
			AVCodecContext *codec = pFormatCtx->streams[i]->codec;
			if(codec->codec_type==CODEC_TYPE_VIDEO){
				width  = (NSUInteger) codec->width;
				height = (NSUInteger) codec->height;
//				NSLog(@"Size: %ix%i",width,height);
				break;
			}
		}
		
		av_close_input_file(pFormatCtx);
		
		[video setFormat: name ];
		[video setWidth:  [NSNumber numberWithInt:width ] ];
		[video setHeight: [NSNumber numberWithInt:height] ];
		
		NSLog(@"Video %@ has: fmt %@, %@x%@",[video path], [video format], [video width], [video height]);
	}
	
//	NSLog(@"Ending info operation");
}

@end
