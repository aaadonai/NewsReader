//
//  NewsFeedCell.m
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import "NewsFeedCell.h"

@interface NewsFeedCell() {
    UILabel     *headlineLabel;
    UILabel     *slugLineLabel;
    UILabel     *datelineLabel;
    UIImageView *imageView;
}

@end


@implementation NewsFeedCell

@synthesize headlineLabel;
@synthesize slugLineLabel;
@synthesize datelineLabel;
@synthesize imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor lightGrayColor]];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        // Create Headline Label
        CGRect headlineFrame = CGRectMake(kCellPaddingLeft, kCellPadding, self.superview.frame.size.width, kDefaultHeight);
        headlineLabel = [[[UILabel alloc] initWithFrame:headlineFrame] autorelease];
        headlineLabel.textColor = kDarkBlue;
        headlineLabel.backgroundColor = [UIColor clearColor];
        headlineLabel.numberOfLines = 0;
        
        headlineLabel.font = [UIFont fontWithName:kHeadlineFont size:kHeadlineFontSize];
        
        //headlineLabel.layer.borderColor = [[UIColor greenColor] CGColor];
        //headlineLabel.layer.borderWidth =2;

        [self addSubview:headlineLabel];
        
        // Create Slugline Label
        CGRect sluglineFrame = CGRectMake(kCellPaddingLeft, kCellPadding + kDefaultHeight, self.superview.frame.size.width, kDefaultHeight);
        slugLineLabel = [[[UILabel alloc] initWithFrame:sluglineFrame] autorelease];
        slugLineLabel.textColor = [UIColor blackColor];
        slugLineLabel.backgroundColor = [UIColor clearColor];
        slugLineLabel.numberOfLines = 0;
        
        slugLineLabel.font = [UIFont systemFontOfSize:kSluglineFontSize];
        
        //slugLineLabel.layer.borderColor = [[UIColor redColor] CGColor];
        //slugLineLabel.layer.borderWidth =2;
        
        [self addSubview:slugLineLabel];

        // Create UIImageView
        CGRect imageViewFrame = CGRectMake(kImageWidth - kCellPaddingRigth, kCellPadding + kDefaultHeight, kImageWidth, kImageHeight);
        imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        
        [self addSubview:imageView];
        
        // Create Dateline Label
        CGRect datelineFrame = CGRectMake(kCellPaddingLeft, kCellPadding + headlineLabel.frame.size.height + slugLineLabel.frame.size.height, self.superview.frame.size.width, kDefaultHeight);
        datelineLabel = [[[UILabel alloc] initWithFrame:datelineFrame] autorelease];
        datelineLabel.textColor = [UIColor darkGrayColor];
        datelineLabel.backgroundColor = [UIColor clearColor];
        
        datelineLabel.font = [UIFont systemFontOfSize:kDatelineFontSize];
        
        //datelineLabel.layer.borderColor = [[UIColor redColor] CGColor];
        //datelineLabel.layer.borderWidth =2;
        
        [self addSubview:datelineLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Custom methods

// Will return Headline height based on text and font
+ (CGFloat) heightOfHeadline: (NSString *)content withWidth:(CGFloat) width {
    CGFloat contentHeight =
    [content sizeWithFont: [UIFont fontWithName:kHeadlineFont size:kHeadlineFontSize]
        constrainedToSize: CGSizeMake(width - kCellPaddingLeft - kCellPaddingRigth, MAXFLOAT )
            lineBreakMode: UILineBreakModeWordWrap].height;
    return contentHeight + kCellPadding;
}

// Will return Slugline height based on text and font
+ (CGFloat) heightOfSlugline: (NSString *)content withWidth:(CGFloat) width {
    CGFloat contentHeight =
    [content sizeWithFont: [UIFont systemFontOfSize:kSluglineFontSize]
        constrainedToSize: CGSizeMake(width - kCellPaddingLeft - kCellPaddingRigth, MAXFLOAT )
            lineBreakMode: UILineBreakModeWordWrap].height;
    return contentHeight + kFooterCellPadding;

}

// Will return Dateline height based on text and font
+ (CGFloat) heightOfDateline: (NSString *)content withWidth:(CGFloat) width {
    CGFloat contentHeight =
    [content sizeWithFont: [UIFont systemFontOfSize:kDatelineFontSize]
        constrainedToSize: CGSizeMake(width - kCellPaddingLeft - kCellPaddingRigth, MAXFLOAT )
            lineBreakMode: UILineBreakModeWordWrap].height;
    return contentHeight;
    
}

- (void)dealloc {
    [headlineLabel release];
    [slugLineLabel release];
    [datelineLabel release];
    [imageView release];
    
    [super dealloc];
}


@end
