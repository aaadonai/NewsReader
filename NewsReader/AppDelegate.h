//
//  AppDelegate.h
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsReaderViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;

@property (nonatomic, retain) NewsReaderViewController *newsReaderViewController;

@end
