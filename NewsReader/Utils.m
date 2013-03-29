//
//  Utils.m
//  NewsReader
//
//  Created by Antonio Rodrigues on 29/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import "Utils.h"

@implementation Utils

// Will calculate label size based on label text and font
+ (CGSize)getLabelSize:(UILabel *)label withConstrainedWidth:(CGFloat) constrainedWidth {
    return [label.text sizeWithFont:label.font
                  constrainedToSize:CGSizeMake(constrainedWidth, MAXFLOAT)
                      lineBreakMode:UILineBreakModeWordWrap];

}

@end
