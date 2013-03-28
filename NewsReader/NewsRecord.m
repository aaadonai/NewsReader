//
//  NewsRecord.m
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import "NewsRecord.h"

@implementation NewsRecord

@synthesize newsHeadline;
@synthesize slugLine;
@synthesize newsImage;
@synthesize dateLine;
@synthesize thumbnailImageURLString;
@synthesize newsURLString;

- (void)dealloc
{
    [newsHeadline release];
    [slugLine release];
    [newsImage release];
    [dateLine release];
    [thumbnailImageURLString release];
    [newsURLString release];
    
    [super dealloc];
}


@end
