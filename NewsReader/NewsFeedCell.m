//
//  NewsFeedCell.m
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import "NewsFeedCell.h"

@implementation NewsFeedCell

@synthesize headlineLabel;
@synthesize slugLineLabel;
@synthesize datelineLabel;
@synthesize imageView;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor lightGrayColor]];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        // Create Headline Label
        CGRect headlineFrame = CGRectMake(kCellPaddingLeft,
                                          kCellPadding,
                                          self.superview.frame.size.width,
                                          kDefaultHeight);
        self.headlineLabel = [[[UILabel alloc] initWithFrame:headlineFrame]
                                  autorelease];
        self.headlineLabel.textColor = kDarkBlue;
        self.headlineLabel.backgroundColor = [UIColor clearColor];
        self.headlineLabel.numberOfLines = 0;
        
        self.headlineLabel.font = [UIFont fontWithName:kHeadlineFont
                                                  size:kHeadlineFontSize];
        
        //self.headlineLabel.layer.borderColor = [[UIColor greenColor] CGColor];
        //self.headlineLabel.layer.borderWidth =2;

        [self addSubview:self.headlineLabel];
        
        // Create Slugline Label
        CGRect sluglineFrame = CGRectMake(kCellPaddingLeft,
                                          kCellPadding + kDefaultHeight,
                                          self.superview.frame.size.width,
                                          kDefaultHeight);
        self.slugLineLabel = [[[UILabel alloc] initWithFrame:sluglineFrame]
                                  autorelease];
        self.slugLineLabel.textColor = [UIColor blackColor];
        self.slugLineLabel.backgroundColor = [UIColor clearColor];
        self.slugLineLabel.numberOfLines = 0;
        
        self.slugLineLabel.font = [UIFont systemFontOfSize:kSluglineFontSize];
        
        //self.slugLineLabel.layer.borderColor = [[UIColor redColor] CGColor];
        //self.slugLineLabel.layer.borderWidth =2;
        
        [self addSubview:self.slugLineLabel];

        // Create UIImageView
        CGRect imageViewFrame = CGRectMake(kImageWidth - kCellPaddingRigth,
                                           kCellPadding + kDefaultHeight,
                                           kImageWidth,
                                           kImageHeight);
        self.imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        
        [self addSubview:self.imageView];
        
        // Create Dateline Label
        CGFloat datelineFrameY = kCellPadding +
                                 self.headlineLabel.frame.size.height +
        self.slugLineLabel.frame.size.height;
        CGRect datelineFrame = CGRectMake(kCellPaddingLeft,
                                          datelineFrameY,
                                          self.superview.frame.size.width,
                                          kDefaultHeight);
        self.datelineLabel = [[[UILabel alloc] initWithFrame:datelineFrame]
                                  autorelease];
        self.datelineLabel.textColor = [UIColor darkGrayColor];
        self.datelineLabel.backgroundColor = [UIColor clearColor];
        
        self.datelineLabel.font = [UIFont systemFontOfSize:kDatelineFontSize];
        
        //self.datelineLabel.layer.borderColor = [[UIColor redColor] CGColor];
        //self.datelineLabel.layer.borderWidth =2;
        
        [self addSubview:self.datelineLabel];
        
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
    CGFloat constrainedWidth = width - kCellPaddingLeft - kCellPaddingRigth;
    CGFloat contentHeight =
    [content sizeWithFont: [UIFont fontWithName:kHeadlineFont
                                           size:kHeadlineFontSize]
        constrainedToSize: CGSizeMake(constrainedWidth, MAXFLOAT)
            lineBreakMode: UILineBreakModeWordWrap].height;
    return contentHeight + kCellPadding;
}

// Will return Slugline height based on text and font
+ (CGFloat) heightOfSlugline: (NSString *)content withWidth:(CGFloat) width {
    CGFloat constrainedWidth = width - kCellPaddingLeft - kCellPaddingRigth;
    CGFloat contentHeight =
    [content sizeWithFont: [UIFont systemFontOfSize:kSluglineFontSize]
        constrainedToSize: CGSizeMake(constrainedWidth, MAXFLOAT)
            lineBreakMode: UILineBreakModeWordWrap].height;
    return contentHeight + kFooterCellPadding;

}

// Will return Dateline height based on text and font
+ (CGFloat) heightOfDateline: (NSString *)content withWidth:(CGFloat) width {
    CGFloat constrainedWidth = width - kCellPaddingLeft - kCellPaddingRigth;
    CGFloat contentHeight =
    [content sizeWithFont: [UIFont systemFontOfSize:kDatelineFontSize]
        constrainedToSize: CGSizeMake(constrainedWidth, MAXFLOAT)
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
