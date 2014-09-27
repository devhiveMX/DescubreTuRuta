//
//  GPSLocationsParser.h
//  HeartsLocator
//
//  Created by Leonardo Cid on 04/07/11.
//  Copyright 2011 Latino Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StoreLocation;
@class GPSLocationsParser;
@protocol GPSLocationsParserDelegate <NSObject>
@required
- (void)gpsLocationsParserDidFinishParse:(GPSLocationsParser*)parser;
@optional
- (void)gpsLocationsParser:(GPSLocationsParser*)parser didFailToWithError:(NSError*)error;
@end

@interface GPSLocationsParser : NSObject <NSXMLParserDelegate>{
    NSMutableData *responseData;
    NSMutableArray *results;
    NSXMLParser *xmlParser;
    
    NSString *currentTagName;
    NSMutableDictionary *currentLocationDict;
    NSMutableString *currentContent;
    NSURLConnection *connection;
}

@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSMutableArray *results;
@property (nonatomic, retain) NSMutableDictionary *currentLocationDict;
@property (nonatomic, retain) NSXMLParser *xmlParser;
@property (nonatomic, assign) id<GPSLocationsParserDelegate> delegate;
@property (nonatomic, retain) NSURLConnection *connection;

- (void)parseXMLFileAtURL:(NSString *)URL;
- (void)parseXMLAtURL:(NSString *)URL;
+ (GPSLocationsParser*)parser;
- (void)cancel;
@end
