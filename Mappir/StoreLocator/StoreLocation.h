

#import <Foundation/Foundation.h>
#import <MapKit/MKUserLocation.h>

typedef enum {
    BusinessIDSams = 2,
    BusinessIDSuperama,
    BusinessIDSupercenter,
}BusinessID;

@interface StoreLocation : NSObject {
    CLLocationCoordinate2D coordinate;
    CLLocationCoordinate2D locationSpan;
    NSInteger storeID;
    NSString *storeAddress;
    NSString *storeName;
    NSString *storeManager;
    NSString *storeSchedule;
    NSString *storeZipcode;
    NSInteger type;
    double tempDistanceToPoint;
    double distanceInMeters;
}

@property (nonatomic, readonly, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, assign) CLLocationCoordinate2D locationSpan;
@property (nonatomic, readonly, assign) NSInteger storeID;
@property (nonatomic, readonly, retain) NSString *storeAddress;
@property (nonatomic, readonly, retain) NSString *storeName;
@property (nonatomic, readonly, retain) NSString *storeManager;
@property (nonatomic, readonly, retain) NSString *storeSchedule;
@property (nonatomic, readonly, retain) NSString *storeZipcode;
@property (nonatomic, readonly, assign) NSInteger type;
@property (nonatomic, assign) double distanceInMeters;
@property (nonatomic, assign) double tempDistanceToPoint;


- (id)initWithDictionary:(NSDictionary*)dictionary;
- (BOOL)isEqualToLocation:(StoreLocation*)aLocation;
+ (StoreLocation*)locationWithDictionary:(NSDictionary*)dict;
+ (NSString *)getTypeFromLocationStoreType:(NSInteger)type;

@end
