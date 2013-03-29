//
//  AppDelegate.m
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import "AppDelegate.h"
#import "NewsReaderViewController.h"

@interface AppDelegate () {
    
    UIWindow *window;
    UINavigationController *navigationController;
    
    // this view controller has the table with news
    NewsReaderViewController *newsReaderViewController;
    
}
@end

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize newsReaderViewController;

- (void)dealloc {
    [navigationController release];
    [newsReaderViewController release];
    
    [window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    newsReaderViewController = [[[NewsReaderViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    
    navigationController = [[[UINavigationController alloc] initWithRootViewController:newsReaderViewController] autorelease];
    
    navigationController.navigationBar.tintColor = kDarkBlue;
    
    [self.window addSubview:navigationController.view];
      
    self.window.rootViewController = navigationController;
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
