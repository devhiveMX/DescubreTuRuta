//
//  StoreLocation.m
//  WalmartApp
//
//  Created by WALMEX3.0_1_WALMART on 12/09/11.
//  Copyright 2011 Walmart Stores Inc. All rights reserved.
//

#import "StoreLocation.h"

@interface StoreLocation()

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) CLLocationCoordinate2D locationSpan;
@property (nonatomic, assign) NSInteger storeID;
@property (nonatomic, retain) NSString *storeAddress;
@property (nonatomic, retain) NSString *storeName;
@property (nonatomic, retain) NSString *storeManager;
@property (nonatomic, retain) NSString *storeSchedule;
@property (nonatomic, retain) NSString *storeZipcode;
@property (nonatomic, assign) NSInteger type;

@end

@implementation StoreLocation
@synthesize coordinate;
@synthesize locationSpan;
@synthesize storeID;
@synthesize storeAddress;
@synthesize storeName;
@synthesize storeManager;
@synthesize storeZipcode;
@synthesize storeSchedule;
@synthesize type;
@synthesize tempDistanceToPoint;
@synthesize distanceInMeters;

- (id)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        self.coordinate = CLLocationCoordinate2DMake([[dictionary objectForKey:@"latpoint"] doubleValue], [[dictionary objectForKey:@"lonpoint"] doubleValue]);
        self.locationSpan = CLLocationCoordinate2DMake([[dictionary objectForKey:@"latspan"] doubleValue], [[dictionary objectForKey:@"lonspan"] doubleValue]);
        self.storeID = [[dictionary objectForKey:@"storeid"] intValue];
        self.type = [[dictionary objectForKey:@"businessid"] intValue];
        self.storeName = [dictionary objectForKey:@"name"];
        self.storeAddress = [dictionary objectForKey:@"address"];
        self.storeManager = [dictionary objectForKey:@"manager"];
        self.storeSchedule = [dictionary objectForKey:@"opens"];
        self.storeZipcode = [dictionary objectForKey:@"zipcode"];

    }
    return self;
}

- (void)dealloc {
    self.storeAddress = nil;
    self.storeName = nil;
    self.storeManager = nil;
    self.storeSchedule = nil;
    self.storeZipcode = nil;
}

- (BOOL)isEqualToLocation:(StoreLocation*)aLocation {
    if (!(self.coordinate.latitude == aLocation.coordinate.latitude && self.coordinate.longitude == aLocation.coordinate.longitude))
        return NO;
    if (!(self.locationSpan.latitude == aLocation.locationSpan.latitude && self.locationSpan.longitude == aLocation.locationSpan.longitude))
        return NO;
    if (self.storeID != aLocation.storeID)return NO;
    if (self.type != aLocation.type) return NO;
    if (![self.storeName isEqualToString:aLocation.storeName]) return NO;
    if (![self.storeAddress isEqualToString:aLocation.storeAddress]) return NO;
    if (self.storeManager && ![self.storeManager isEqualToString:aLocation.storeManager]) return NO;
    if (self.storeSchedule && ![self.storeSchedule isEqualToString:aLocation.storeSchedule]) return NO;
    if (self.storeZipcode && ![self.storeZipcode isEqualToString:aLocation.storeZipcode]) return NO;
    return YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{StoreID: %d\n\tLocation Latitude: %g\n\tLocation Longitude: %g\n\tName: \"%@\",\n\tAddress: \"%@\"\n\tStore Type: %@\n}", self.storeID, self.coordinate.latitude, self.coordinate.longitude, self.storeName, self.storeAddress, [StoreLocation getTypeFromLocationStoreType:self.type]];
}

+ (StoreLocation*)locationWithDictionary:(NSDictionary*)dict {
    StoreLocation *newLocation = [[self alloc] initWithDictionary:dict];
    return newLocation;
}

+ (NSString *)getTypeFromLocationStoreType:(NSInteger)type {
    switch(type) {
        case BusinessIDSams:
            return @"sam";
        case BusinessIDSupercenter:
            return @"wal";
        case BusinessIDSuperama:
            return @"sup";
        default:
            return @"";
    }
}

@end
