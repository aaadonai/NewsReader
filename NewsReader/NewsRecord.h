//
//  NewsRecord.h
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsRecord : NSObject {
    NSString *newsHeadline;
    NSString *slugLine;
    UIImage *newsImage;
    NSString *dateLine;
    NSString *thumbnailImageURLString;
    NSString *newsURLString;
}

@property (nonatomic, retain) NSString *newsHeadline;
@property (nonatomic, retain) NSString *slugLine;
@property (nonatomic, retain) UIImage *newsImage;
@property (nonatomic, retain) NSString *dateLine;
@property (nonatomic, retain) NSString *thumbnailImageURLString;
@property (nonatomic, retain) NSString *newsURLString;

- (BOOL)hasImage;
- (BOOL)hasSlugline;

@end
