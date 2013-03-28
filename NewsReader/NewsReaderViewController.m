//
//  NewsReaderViewController.m
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import "NewsReaderViewController.h"
#import "WebContentViewController.h"

#define kDefaultRowHeight    90.0
#define kDefaultRowCount     10


static NSString *const NewsFeed =
@"http://mobilatr.mob.f2.com.au/services/views/9.json";

@interface NewsReaderViewController (){

    // list of news
    NSMutableArray *newsRecords;

    // url connection to news feed
    NSURLConnection *newsFeedConnection;
    NSMutableData   *newsData;

    // the queue to run the parser
    NSOperationQueue *queue;

    //activity indicator
    UIActivityIndicatorView *activityIndicator;
}

@end

@implementation NewsReaderViewController

@synthesize newsRecords;
@synthesize newsEntries;
@synthesize newsFeedConnection;
@synthesize newsData;
@synthesize queue;
@synthesize imageDownloadsInProgress;



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.tableView.rowHeight = kDefaultRowHeight;
    
    // Initilize array of news and pass a reference to the view controller
    self.newsRecords = [NSMutableArray array];
    self.newsEntries = self.newsRecords;
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:NewsFeed]];
    self.newsFeedConnection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
    
    
    //adding spinner
    activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    UIBarButtonItem *activity = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [[self navigationItem] setRightBarButtonItem:activity];
    [activity release];
    
    [activityIndicator startAnimating];
    
}

- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
    
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
}

#pragma mark - Table view data source

// customize the number of rows in the table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [newsEntries count];
    
    // return rows to fill the screen
    if (count == 0)
    {
        return kDefaultRowCount;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // customize the appearance of table view cells
    //
    static NSString *CellIdentifier = @"LazyTableCell";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    
    // add a placeholder cell while waiting on table data
    int nodeCount = [self.newsEntries count];
    
    if (nodeCount == 0 && indexPath.row == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                           reuseIdentifier:PlaceholderCellIdentifier] autorelease];
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;

        }
        
        cell.detailTextLabel.text = @"Loading…";
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;

    }
    
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
    {
        // Set up the cell...
        NewsRecord *newsRecord = [self.newsEntries objectAtIndex:indexPath.row];
        NSLog(@"indexPath.row: %d",indexPath.row);
        cell.textLabel.text = newsRecord.newsHeadline;
        cell.detailTextLabel.text = newsRecord.slugLine;
        
        // Only load cached images; defer new downloads until scrolling ends
        if (!newsRecord.newsImage)
        {
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                if (![newsRecord.thumbnailImageURLString isKindOfClass:[NSNull class]]) {
                    [self startImageDownload:newsRecord forIndexPath:indexPath];
                    NSLog(@"startImageDownload indexPath.row: %d",indexPath.row);
                   // cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
                }
            }
            // if a download is deferred or in progress, return a placeholder image
            cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        }
        else
        {
            cell.imageView.image = newsRecord.newsImage;
        }
        
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NewsRecord *newsRecord = [self.newsEntries objectAtIndex:indexPath.row];
    
    // Create and push another view controller.
    WebContentViewController *webContentViewController = [[WebContentViewController alloc] initWithNewsRecord:newsRecord];
    
    
    // Pass the selected object to the new view controller.
    //[self.navigationController pushViewController:webContentViewController animated:YES];
    //[webContentViewController release];
     [self.navigationController pushViewController:webContentViewController animated:YES];
    
}

//  Method handles loaded news and name
- (void)handleLoadedNewsAndName:(NSArray *)loadedNews andName:(NSString *)name
{
    [self.newsRecords addObjectsFromArray:loadedNews];
    [self.navigationItem setTitle:name];
    // tell our table view to reload its data, now that parsing has completed
    [self.tableView reloadData];
}


#pragma mark - NSURLConnection delegate methods

//  Delegate method to handle error messages
- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Show News Feed"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

//  Delegate method called when connection did receive a response
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.newsData = [NSMutableData data];    // start off with new data
}

//  Delegate method called when connection did receive data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [newsData appendData:data];  // append incoming data
}

//  Delegate method called when connection fails
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet)
    {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No Connection Error"
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    }
    else
    {
        // otherwise handle the error generically
        [self handleError:error];
    }
    
    self.newsFeedConnection = nil;   // release our connection
}

//  Delegate method called when connection did finish loading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.newsFeedConnection = nil;   // release our connection
    
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [activityIndicator stopAnimating];
    
    // create the queue to run our ParseOperation
    self.queue = [[[NSOperationQueue alloc] init] autorelease];
    
    // create an ParseOperation to parse the feed data (UI won't be blocked)
    ParseOperation *parser = [[ParseOperation alloc] initWithData:newsData
                                                completionHandler:^(NSArray *newsList, NSString *name) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        [self handleLoadedNewsAndName:newsList andName:name];
                                                        
                                                    });
                                                    
                                                    self.queue = nil;   // we are finished with the queue and our ParseOperation
                                                }];
    
    parser.errorHandler = ^(NSError *parseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self handleError:parseError];
            
        });
    };
    
    [queue addOperation:parser]; // starts "ParseOperation"
    
    [parser release];
    
    self.newsData = nil;
}

#pragma mark - Method for ImageDownloaderDelegate

// called by our ImageDownloader when an image is ready to be displayed
- (void)newsImageDidLoad:(NSIndexPath *)indexPath
{
    ImageDownloader *imageDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (imageDownloader != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:imageDownloader.indexPathInTableView];
        
        // Display the new image just loaded
        cell.imageView.image = imageDownloader.newsRecord.newsImage;
    }
    
    // Remove the IconDownloader from the in progress list.
    // This will result in it being deallocated.
    [imageDownloadsInProgress removeObjectForKey:indexPath];
}

#pragma mark - Custom methods

// Starts image download
- (void)startImageDownload:(NewsRecord *)newsRecord forIndexPath:(NSIndexPath *)indexPath
{
    ImageDownloader *imageDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (imageDownloader == nil)
    {
        imageDownloader = [[ImageDownloader alloc] init];
        imageDownloader.newsRecord = newsRecord;
        imageDownloader.indexPathInTableView = indexPath;
        imageDownloader.delegate = self;
        [imageDownloadsInProgress setObject:imageDownloader forKey:indexPath];
        [imageDownloader startDownload];
        [imageDownloader release];
    }
}

// this method is used in case the user scrolled the list to a point where the cells don't have image yet
- (void)loadImagesForOnscreenRows
{
    if ([self.newsEntries count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NewsRecord *newsRecord = [self.newsEntries objectAtIndex:indexPath.row];
            // won't download if the news already has an image
            // or if has no image on feed
            if (!newsRecord.newsImage && ![newsRecord.thumbnailImageURLString isKindOfClass:[NSNull class]])
            {
                [self startImageDownload:newsRecord forIndexPath:indexPath];
            }
        }
    }
}

#pragma mark - Methods for UIScrollViewDelegate

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

// Load images when scrolling ends decelerating
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)dealloc {
    
    [newsRecords release];

    [newsEntries release];
    [imageDownloadsInProgress release];

    
    [newsFeedConnection release];
    [newsData release];
    
    [activityIndicator release];
    [super dealloc];
}

@end
