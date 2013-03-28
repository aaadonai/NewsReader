//
//  WebContentViewController.h
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsRecord;

@interface WebContentViewController : UIViewController

@property (nonatomic,retain) NewsRecord *newsRecord;

- (id)initWithNewsRecord:(NewsRecord*) newsRecord;

@end
