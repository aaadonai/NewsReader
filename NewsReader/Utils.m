//
//  Utils.m
//  NewsReader
//
//  Created by Antonio Rodrigues on 29/03/13.
//  Copyright (c) 2013 Antonio Rodrigues. All rights reserved.
//

#import "Utils.h"

@implementation Utils

// Will calculate label size based on label text and font
+ (CGSize)getLabelSize:(UILabel *)label withConstrainedWidth:(CGFloat) constrainedWidth {
    return [label.text sizeWithFont:label.font
                  constrainedToSize:CGSizeMake(constrainedWidth, MAXFLOAT)
                      lineBreakMode:UILineBreakModeWordWrap];

}

// Will convert the dateline from the format in the JSON to a nice date format
+ (NSString *)datelineToDisplay:(NSString *)dateline {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //2013-03-30T03:00:00+11:00 - example JSON dateline
    NSDate *date = [Utils parseRFC3339Date:dateline];
    [dateFormatter setDateFormat:@"EEEE - MMMM dd, yyyy HH:mm a"];
    NSString* stringDateToReturn = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    return stringDateToReturn;
}

// This function was copied from Stackoverflow
// http://stackoverflow.com/questions/3094819/nsdateformatter-returning-nil-in-os-4-0#3968411
// 
+ (NSDate *)parseRFC3339Date:(NSString *)dateString
{
    NSDateFormatter *rfc3339TimestampFormatterWithTimeZone = [[NSDateFormatter alloc] init];
    [rfc3339TimestampFormatterWithTimeZone setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
    [rfc3339TimestampFormatterWithTimeZone setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSDate *theDate = nil;
    NSError *error = nil;
    if (![rfc3339TimestampFormatterWithTimeZone getObjectValue:&theDate forString:dateString range:nil error:&error]) {
        NSLog(@"Date '%@' could not be parsed: %@", dateString, error);
    }
    
    [rfc3339TimestampFormatterWithTimeZone release];
    return theDate;
}

@end
