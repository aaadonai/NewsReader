//
//  ImageDownloader.h
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NewsRecord;
@class NewsReaderViewController;

@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSObject
{
    NewsRecord *appRecord;
    NSIndexPath *indexPathInTableView;
    id <ImageDownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
}

@property (nonatomic, retain) NewsRecord *newsRecord;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <ImageDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol ImageDownloaderDelegate

- (void)newsImageDidLoad:(NSIndexPath *)indexPath;

@end