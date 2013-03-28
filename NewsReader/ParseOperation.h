//
//  ParseOperation.h
//  NewsReader
//
//  Created by Antonio Rodrigues on 28/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HandlerBlock)(NSArray *, NSString *name);
typedef void (^ErrorBlock)(NSError *);

@class NewsRecord;

@interface ParseOperation : NSOperation {
@private
    HandlerBlock    completionHandler;
    ErrorBlock      errorHandler;
    
    NSData          *dataToParse;
    
    NSMutableArray  *workingArray;
    NewsRecord      *workingEntry;
    NSString        *feedName;
}

@property (nonatomic, copy) ErrorBlock errorHandler;

@property (nonatomic, copy) HandlerBlock completionHandler;
@property (nonatomic, retain) NSData *dataToParse;
@property (nonatomic, retain) NSMutableArray *workingArray;
@property (nonatomic, retain) NewsRecord *workingEntry;
@property (nonatomic, copy) NSString *feedName;


- (id)initWithData:(NSData *)data completionHandler:(HandlerBlock)handler;

@end