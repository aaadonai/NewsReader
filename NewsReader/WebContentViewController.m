//
//  WebContentViewController.m
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import "WebContentViewController.h"
#import "NewsRecord.h"

@interface WebContentViewController ()

@end

@implementation WebContentViewController

- (id)initWithNewsRecord:(NewsRecord*) newsRecord{
    self = [super init];
    if (self) {
        // Custom initialization
        // Set news record
        self.newsRecord = newsRecord;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Create UIWebView
    UIWebView *webView = [[UIWebView alloc] init];
    
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:self.newsRecord.newsURLString];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [webView loadRequest:requestObj];
    
    // will allow pinch to zoom in and out
    [webView setScalesPageToFit:YES];
    
    [self setTitle:self.newsRecord.newsHeadline];
    [self setView:webView];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
