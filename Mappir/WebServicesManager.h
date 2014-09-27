//
//  WebServicesManager.h
//  WalmartApp
//
//  Created by WALMEX3.0_1_WALMART on 15/09/11.
//  Copyright 2011 Walmart Stores Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSConnection.h"

@protocol WebServicesObserver;
@interface WebServicesManager : NSObject <WSConnectionDelegate> {
    NSMutableDictionary *currentConnections;
}
@property (nonatomic, retain) NSMutableDictionary *currentConnections;

- (void)loadConnection:(WSConnection*)connection withObserver: (id<WebServicesObserver>)observer;
- (void)removeObserver:(id<WebServicesObserver>)observer;
+(WebServicesManager*)defaultManager;
+(void)connectWithType:(WSConnectionType)connectionType singleParam:(NSString*)param jsonParam:(NSString*)jsonParam originLocation:(CLLocationCoordinate2D)origin destLocation:(CLLocationCoordinate2D)destination withObserver:(id<WebServicesObserver>)observer;
@end

@protocol WebServicesObserver<NSObject>
@optional
- (void)webServicesConnectionDidFinish:(NSNotification*)notification; // userInfo will contain data
- (void)webServicesConnectionDidFail:(NSNotification*)notification; // userInfo will contain error

@end



