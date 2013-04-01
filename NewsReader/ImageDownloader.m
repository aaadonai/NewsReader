//
//  ImageDownloader.m
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import "ImageDownloader.h"
#import "NewsRecord.h"

@implementation ImageDownloader

@synthesize newsRecord;
@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;

#pragma mark

- (void)dealloc {
    [newsRecord release];
    [indexPathInTableView release];
    
    [activeDownload release];
    
    [imageConnection cancel];
    [imageConnection release];
    
    [super dealloc];
}

- (void)startDownload {
    self.activeDownload = [NSMutableData data];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                                        [NSURLRequest requestWithURL:
                                        [NSURL URLWithString:
                                        newsRecord.thumbnailImageURLString]]
                                        delegate:self];
    self.imageConnection = conn;
    [conn release];
}

- (void)cancelDownload {
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection
            didFailWithError:(NSError *)error {
    // Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Set temporary image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    
    if (image.size.width != kImageWidth || image.size.height != kImageHeight) {
        CGSize itemSize = CGSizeMake(kImageWidth, kImageHeight);
        UIGraphicsBeginImageContext(itemSize);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [image drawInRect:imageRect];
        self.newsRecord.newsImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else     {
        self.newsRecord.newsImage = image;
    }
    
    self.activeDownload = nil;
    [image release];
    
    // will release the connection 
    self.imageConnection = nil;
    
    // call delegate when image is ready to display
    [delegate newsImageDidLoad:self.indexPathInTableView];
}

@end
