//
//  ParseOperation.m
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import "ParseOperation.h"
#import "NewsRecord.h"

// string contants found in the RSS feed
static NSString *kHeadLineStr = @"headLine";
static NSString *kSlugLineStr = @"slugLine";
static NSString *kNameStr     = @"name";

static NSString *kImageURLStr = @"thumbnailImageHref";
static NSString *kDateLineStr = @"dateLine";
static NSString *kNewsURLStr  = @"webHref";

static NSString *kItemsStr  = @"items";



@interface ParseOperation ()
@end

@implementation ParseOperation

@synthesize completionHandler;
@synthesize errorHandler;
@synthesize dataToParse;
@synthesize workingArray;
@synthesize workingEntry;
@synthesize feedName;

- (id)initWithData:(NSData *)data completionHandler:(HandlerBlock)handler
{
    self = [super init];
    if (self != nil)
    {
        self.dataToParse = data;
        self.completionHandler = handler;
    }
    return self;
}

- (void)main{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    self.workingArray = [NSMutableArray array];
    
    NSError *error = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData: self.dataToParse options: NSJSONReadingMutableContainers error: &error];
    
    if (!jsonDictionary) {
        NSLog(@"Error parsing JSON: %@", error);
        self.errorHandler(error);
    } else {
        [self parseWithJSONDictionary:jsonDictionary];
    }
    
    if (![self isCancelled])
    {
        // call our completion handler with the result of our parsing
        self.completionHandler(self.workingArray, self.feedName);
    }
    
    self.workingArray = nil;
    self.dataToParse = nil;
    
    [pool release];
    
}

- (void)parseWithJSONDictionary:(NSDictionary *) jsonDictionary {
    
    self.feedName = [jsonDictionary objectForKey:kNameStr];
    NSArray *newsItemsArray = [jsonDictionary objectForKey:kItemsStr];
    int count = 0;
    for (NSDictionary *newsItem in newsItemsArray) {
        workingEntry = [[NewsRecord alloc] init];
        NSLog(@"%d: %@",count++,[newsItem objectForKey:kHeadLineStr]);
        workingEntry.dateLine = [newsItem objectForKey:kDateLineStr];
        workingEntry.newsHeadline = [newsItem objectForKey:kHeadLineStr];
        // slugline can sometimes be null
        if ([[newsItem objectForKey:kSlugLineStr] isKindOfClass:[NSNull class]]){
            workingEntry.slugLine = nil;
        } else {
            workingEntry.slugLine = [newsItem objectForKey:kSlugLineStr];
        }
        // thumbnailImageURL can sometimes be null
        if ([[newsItem objectForKey:kImageURLStr] isKindOfClass:[NSNull class]]) {
            workingEntry.thumbnailImageURLString = nil;
        } else {
            workingEntry.thumbnailImageURLString = [newsItem objectForKey:kImageURLStr];
        }
        workingEntry.newsURLString = [newsItem objectForKey:kNewsURLStr];
        [self.workingArray addObject:workingEntry];
        
    }
    
}

- (void)dealloc {
    [completionHandler release];
    [errorHandler release];
    [dataToParse release];
    [workingEntry release];
    [workingArray release];
    [feedName release];
    
    [super dealloc];
}

@end
