//
//  NewsFeedCell.h
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ImageDownloader.h"

#define kCellPadding 10.0f
#define kFooterCellPadding 5.0f
#define kCellPaddingLeft 5.0f
// note that cell will have Accessory (>)
// and kCellPaddingRight starts from it.
#define kCellPaddingRigth 5.0f 
#define kDefaultHeight 10.0f
#define kHeadlineFontSize 20.0f
#define kSluglineFontSize 14.0f
#define kDatelineFontSize 10.0f

#define kHeadlineFont @"TimesNewRomanPSMT"

@interface NewsFeedCell : UITableViewCell

@property (nonatomic, retain) UILabel     *headlineLabel;
@property (nonatomic, retain) UILabel     *slugLineLabel;
@property (nonatomic, retain) UILabel     *datelineLabel;
@property (nonatomic, retain) UIImageView *imageView;

+ (CGFloat) heightOfHeadline: (NSString *)content withWidth:(CGFloat) width;
+ (CGFloat) heightOfSlugline: (NSString *)content withWidth:(CGFloat) width;
+ (CGFloat) heightOfDateline: (NSString *)content withWidth:(CGFloat) width;

@end
