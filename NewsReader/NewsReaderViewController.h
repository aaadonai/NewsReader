//
//  NewsReaderViewController.h
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseOperation.h"
#import "NewsRecord.h"
#import "ImageDownloader.h"

@interface NewsReaderViewController : UITableViewController<UIScrollViewDelegate, ImageDownloaderDelegate>
{
    NSArray *newsEntries;   // the main data model for our UITableView
    NSMutableDictionary *imageDownloadsInProgress;  // the set of IconDownloader objects for each app
}

@property (nonatomic, retain) NSArray *newsEntries;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;


@property (nonatomic, retain) NSMutableArray *newsRecords;

@property (nonatomic, retain) NSOperationQueue *queue;

@property (nonatomic, retain) NSURLConnection *newsFeedConnection;
@property (nonatomic, retain) NSMutableData *newsData;

- (void)newsImageDidLoad:(NSIndexPath *)indexPath;

@end
