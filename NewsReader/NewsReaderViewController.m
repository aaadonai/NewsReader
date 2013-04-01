//
//  NewsReaderViewController.m
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import "NewsReaderViewController.h"
#import "WebContentViewController.h"
#import "NewsFeedCell.h"
#import "Utils.h"

#define kDefaultRowHeight    90.0
#define kDefaultRowCount     10
#define kDefaultCellHeight   80

static NSString *const NewsFeed =
    @"http://mobilatr.mob.f2.com.au/services/views/9.json";

@interface NewsReaderViewController() {

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

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // will adjust subviews' frames for visible cells
    [self reframeForVisibleCells];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.tableView.rowHeight = kDefaultRowHeight;
    
    // Initilize array of news and pass a reference to the view controller
    self.newsRecords = [NSMutableArray array];
    self.newsEntries = self.newsRecords;
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
                                [NSURL URLWithString:NewsFeed]];
    self.newsFeedConnection = [[[NSURLConnection alloc]
                                initWithRequest:urlRequest delegate:self]
                                autorelease];
    
    //adding spinner
    activityIndicator = [[[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:
                          UIActivityIndicatorViewStyleWhite] autorelease];
    UIBarButtonItem *activity = [[UIBarButtonItem alloc]
                                 initWithCustomView:activityIndicator];
    [[self navigationItem] setRightBarButtonItem:activity];
    [activity release];
    
    [activityIndicator startAnimating];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
    
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
}

#pragma mark - Table view data source

// customize the number of rows in the table view
- (NSInteger)tableView:(UITableView *)tableView
                 numberOfRowsInSection:(NSInteger)section {
    int count = [newsEntries count];
    
    // return rows to fill the screen
    if (count == 0)
    {
        return kDefaultRowCount;
    }
    return count;
}

// customize the row height
- (CGFloat)tableView:(UITableView *)tableView
               heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat heightToReturn = 0;
    int newsCount = [self.newsEntries count];
    if (newsCount > 0) {
        
        // Magic Number Warning
        //at this point can't define Accessory (>) width programmatically
        float cellAccessoryViewWidth = 20; 
        
        float width = [self cellWidthWithScreenBoundsAndDeviceOrientation] -
                       cellAccessoryViewWidth -
                       kCellPaddingLeft -
                       kCellPaddingRigth;
        NewsRecord *newsRecord = [self.newsEntries objectAtIndex:indexPath.row];
        CGFloat headLineHeight = [NewsFeedCell
                                  heightOfHeadline:newsRecord.newsHeadline
                                  withWidth:width];
        
        heightToReturn += headLineHeight;

        CGFloat datelineHeight = [NewsFeedCell
                                  heightOfDateline:newsRecord.dateLine
                                  withWidth:width];
        
        heightToReturn += datelineHeight;
        
        if (newsRecord.hasSlugline && newsRecord.hasImage) {
            CGFloat slugLineHeight = [NewsFeedCell
                                      heightOfSlugline:newsRecord.slugLine
                                      withWidth:width - kImageWidth];
            if (slugLineHeight > kImageHeight){
                heightToReturn += slugLineHeight;
            } else {
                heightToReturn += kImageHeight ;
            }
        } else {
            if (newsRecord.hasImage){
               heightToReturn += kImageHeight;
            } else if (newsRecord.hasSlugline){
                CGFloat slugLineHeight = [NewsFeedCell
                                          heightOfSlugline:newsRecord.slugLine
                                          withWidth:width];
                heightToReturn += slugLineHeight;
            }
        }
    }
    
    if (heightToReturn > 0){
        return heightToReturn;
    }
    return kDefaultCellHeight;
}

// customize the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    
    int newsCount = [self.newsEntries count];
    
    // add a placeholder cell while waiting on table data
    if (newsCount == 0 && indexPath.row == 0) {
        NewsFeedCell *cell = [tableView
                              dequeueReusableCellWithIdentifier:
                              PlaceholderCellIdentifier];
        if (cell == nil) {
            cell = [[[NewsFeedCell alloc]
                       initWithStyle:UITableViewCellStyleSubtitle
                     reuseIdentifier:PlaceholderCellIdentifier] autorelease];
        }
        
        cell.detailTextLabel.text = @"Loading…";
        
        return cell;
    }
    
    NewsFeedCell *cell = [tableView
                          dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NewsFeedCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:CellIdentifier]
                                       autorelease];
    }
    
    // Leave cells empty if there's no data yet
    if (newsCount > 0) {

        // Set up the cell
        NewsRecord *newsRecord = [self.newsEntries objectAtIndex:indexPath.row];
        NSLog(@"indexPath.row: %d",indexPath.row);
        
        cell.headlineLabel.text = newsRecord.newsHeadline;
        cell.slugLineLabel.text = newsRecord.slugLine;
        cell.datelineLabel.text = [Utils datelineToDisplay:newsRecord.dateLine];
        
        NSLog(@"cell.datelineLabel.text: %@", cell.datelineLabel.text);
        
        NSLog(@"cell width: %f", cell.frame.size.width);
        NSLog(@"slugline Y: %f", cell.slugLineLabel.frame.origin.y);
        
        // Only load cached images; defer new downloads until scrolling ends
        if (!newsRecord.newsImage)
        {
            if (self.tableView.dragging == NO &&
                self.tableView.decelerating == NO)
            {
                if (newsRecord.thumbnailImageURLString) {
                    // will start download image in the background and callback
                    // when done
                    [self startImageDownload:newsRecord forIndexPath:indexPath];
                }
            }
            // if a download is deferred or in progress,
            // return a placeholder image
            cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        }
        else
        {
            cell.imageView.image = newsRecord.newsImage;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
            willDisplayCell:(UITableViewCell *)cell
          forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Add gradient Color
    [self setGradientColorToCell:cell];
    
    // will adjust frame to fit cell
    [self reframeCellElements:cell forRowAtIndexPath:indexPath];
    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)
                                         fromInterfaceOrientation {
    [self reframeForVisibleCells];
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
            didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int newsCount = [self.newsEntries count];
    if (newsCount > 0) {
        
        NewsRecord *newsRecord = [self.newsEntries objectAtIndex:indexPath.row];
        
        // Create and push another view controller.
        WebContentViewController *webContentViewController =
        [[WebContentViewController alloc] initWithNewsRecord:newsRecord];
        
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:webContentViewController
                                             animated:YES];
        [webContentViewController release];
    }
}

//  Method handles loaded news and name
- (void)handleLoadedNewsAndName:(NSArray *)loadedNews
                        andName:(NSString *)name {
    [self.newsRecords addObjectsFromArray:loadedNews];
    [self.navigationItem setTitle:name];
    // tell our table view to reload its data, now that parsing has completed
    [self.tableView reloadData];
}


#pragma mark - NSURLConnection delegate methods

//  Delegate method to handle error messages
- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Cannot Show News Feed"
                                        message:errorMessage
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

//  Delegate method called when connection did receive a response
- (void)connection:(NSURLConnection *)connection
            didReceiveResponse:(NSURLResponse *)response {
    self.newsData = [NSMutableData data];    // start off with new data
}

//  Delegate method called when connection did receive data
- (void)connection:(NSURLConnection *)connection
            didReceiveData:(NSData *)data {
    [newsData appendData:data];  // append incoming data
}

//  Delegate method called when connection fails
- (void)connection:(NSURLConnection *)connection
            didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error,
        // we can present a more precise message to the user.
        NSDictionary *userInfo =
               [NSDictionary dictionaryWithObject:@"No Connection Error"
                                           forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError =
                [NSError errorWithDomain:NSCocoaErrorDomain
                                    code:kCFURLErrorNotConnectedToInternet
                                userInfo:userInfo];
        [self handleError:noConnectionError];
    }
    else {
        // otherwise handle the error generically
        [self handleError:error];
    }
    
    self.newsFeedConnection = nil;   // release our connection
}

//  Delegate method called when connection did finish loading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.newsFeedConnection = nil;   // release our connection
    
    [activityIndicator stopAnimating];
    
    // create the queue to run our ParseOperation
    self.queue = [[[NSOperationQueue alloc] init] autorelease];
    
    // create an ParseOperation to parse the feed data (UI won't be blocked)
    ParseOperation *parser = [[ParseOperation alloc]
                                 initWithData:newsData
                            completionHandler:
                                ^(NSArray *newsList, NSString *name) {
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                        [self handleLoadedNewsAndName:newsList
                                                              andName:name];
                                                        
                                    });
                                    // we are finished with the queue and our
                                    // ParseOperation
                                    self.queue = nil;
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
- (void)newsImageDidLoad:(NSIndexPath *)indexPath {
    ImageDownloader *imageDownloader = [imageDownloadsInProgress
                                        objectForKey:indexPath];
    if (imageDownloader != nil) {
        NewsFeedCell *cell = (NewsFeedCell *)[self.tableView
                                              cellForRowAtIndexPath:
                                              imageDownloader
                                              .indexPathInTableView];
        
        // Display the new image just loaded
        cell.imageView.image = imageDownloader.newsRecord.newsImage;
    }
    
    // Remove the IconDownloader from the in progress list.
    // This will result in it being deallocated.
    [imageDownloadsInProgress removeObjectForKey:indexPath];
}

#pragma mark - Custom methods

// will adjust subviews' frames for visible cells
- (void)reframeForVisibleCells {
    NSArray *visibleCells = [self.tableView visibleCells];
    NSLog(@"visible cells count: %d", [visibleCells count]);
    for (UITableViewCell *cell in visibleCells) {
        [self setGradientColorToCell:cell];
        [self reframeCellElements:cell];
    }
}

// will adjust frames to fit cell
- (void)reframeCellElements:(UITableViewCell*)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self reframeCellElements:cell forRowAtIndexPath:indexPath];
}

// will adjust frames to fit cell
- (void)reframeCellElements:(UITableViewCell*)cell
          forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewsFeedCell *newsFeedCell = (NewsFeedCell*)cell;
    
    // Calculates width by disconsidering DisclosureIndicator (>) width to avoid
    // overlapping
    // takes label x origin to consider padding
    float calculatedConstrainedWidth = cell.contentView.frame.size.width -
                                    newsFeedCell.headlineLabel.frame.origin.x -
                                    kCellPaddingRigth; 
    
    CGSize headlineLabelSize = [Utils getLabelSize:newsFeedCell.headlineLabel
                              withConstrainedWidth:calculatedConstrainedWidth];
    
    newsFeedCell.headlineLabel.frame =
                           CGRectMake(newsFeedCell.headlineLabel.frame.origin.x,
                                      newsFeedCell.headlineLabel.frame.origin.y,
                                      headlineLabelSize.width,
                                      headlineLabelSize.height);
    
    if ([self.newsEntries count] > 0) {
        
        NewsRecord *newsRecord = [self.newsEntries objectAtIndex:indexPath.row];
        
        // Will only set sluglineLabel if slugline is available
        if (newsRecord.hasSlugline){
            if (newsRecord.hasImage) {
                // reset calculatedConstrainedWidth
                calculatedConstrainedWidth = calculatedConstrainedWidth -
                                             kImageWidth -
                                             kCellPaddingRigth;
            }
            CGSize sluglineLabelSize = [Utils
                                        getLabelSize:newsFeedCell.slugLineLabel
                                        withConstrainedWidth:
                                        calculatedConstrainedWidth];
            CGFloat sluglineFrameY = newsFeedCell.headlineLabel.frame.origin.y +
                                   newsFeedCell.headlineLabel.frame.size.height;
            newsFeedCell.slugLineLabel.frame =
                           CGRectMake(newsFeedCell.headlineLabel.frame.origin.x,
                                      sluglineFrameY,
                                      sluglineLabelSize.width,
                                      sluglineLabelSize.height);
        }
        
        
        if (newsRecord.hasImage) {
            CGFloat imageViewFrameX = cell.contentView.frame.size.width -
                                      kImageWidth -
                                      kCellPaddingRigth;
            CGFloat imageViewFrameY =
                                newsFeedCell.headlineLabel.frame.origin.y +
            newsFeedCell.headlineLabel.frame.size.height;
            newsFeedCell.imageView.frame = CGRectMake(imageViewFrameX,
                                                      imageViewFrameY,
                                                      kImageWidth,
                                                      kImageHeight);
        }
        
        CGSize datelineLabelSize = [Utils
                                    getLabelSize:newsFeedCell.datelineLabel
                                    withConstrainedWidth:
                                    cell.contentView.frame.size.width];
        CGFloat datelineFrameY = newsFeedCell.frame.size.height -
                                 datelineLabelSize.height -
                                 kFooterCellPadding;
        newsFeedCell.datelineLabel.frame =
                           CGRectMake(newsFeedCell.headlineLabel.frame.origin.x,
                                      datelineFrameY,
                                      datelineLabelSize.width,
                                      datelineLabelSize.height);
    }

}

// Starts image download
- (void)startImageDownload:(NewsRecord *)newsRecord
              forIndexPath:(NSIndexPath *)indexPath {
    
    ImageDownloader *imageDownloader = [imageDownloadsInProgress
                                            objectForKey:indexPath];
    if (imageDownloader == nil) {
        imageDownloader = [[ImageDownloader alloc] init];
        imageDownloader.newsRecord = newsRecord;
        imageDownloader.indexPathInTableView = indexPath;
        imageDownloader.delegate = self;
        [imageDownloadsInProgress setObject:imageDownloader forKey:indexPath];
        [imageDownloader startDownload];
        [imageDownloader release];
    }
}

// this method is used in case the user scrolled the list to where the cells don't have image yet
- (void)loadImagesForOnscreenRows {
    if ([self.newsEntries count] > 0) {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths) {
            NewsRecord *newsRecord = [self.newsEntries
                                          objectAtIndex:indexPath.row];
            // won't download if the news already has an image
            // or if has no image on feed
            if (!newsRecord.newsImage && newsRecord.thumbnailImageURLString) {
                [self startImageDownload:newsRecord forIndexPath:indexPath];
            }
        }
    }
}

// This method set the gradient color to the cell background
- (void)setGradientColorToCell:(UITableViewCell *)cell {
    [cell setBackgroundColor:[UIColor clearColor]];
    
    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame = cell.bounds;
    grad.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor],
                       (id)[[UIColor lightGrayColor] CGColor], nil];
    
    UIView *newBackgroundView = [[UIView alloc] init];
    [cell setBackgroundView:newBackgroundView];
    [cell.backgroundView.layer insertSublayer:grad atIndex:0];
    [newBackgroundView release];
    
    CAGradientLayer *selectedGrad = [CAGradientLayer layer];
    selectedGrad.frame = cell.bounds;
    selectedGrad.colors = [NSArray arrayWithObjects:
                                       (id)[[UIColor lightGrayColor] CGColor],
                                       (id)[[UIColor whiteColor] CGColor],
                                       nil];
    
    UIView *newSelectedView = [[UIView alloc] init];
    [cell setSelectedBackgroundView:newSelectedView];
    [cell.selectedBackgroundView.layer insertSublayer:selectedGrad atIndex:0];
    [newSelectedView release];
    
}

// Calculates cell width screen size and orientation
- (CGFloat) cellWidthWithScreenBoundsAndDeviceOrientation {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    float width = UIDeviceOrientationIsLandscape(orientation) ? screenHeight :
                                                                screenWidth;
    
    return width;
}

#pragma mark - Methods for UIScrollViewDelegate

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadImagesForOnscreenRows];
    }
}

// Load images when scrolling ends decelerating
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenRows];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
                               (UIInterfaceOrientation)toInterfaceOrientation {
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
