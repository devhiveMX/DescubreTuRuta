//
//  HeartMapAnnotation.h
//  HeartsLocator
//
//  Created by WALMEX3.0 _1 WALMART on 05/07/11.
//  Copyright 2011 Latino Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@class StoreLocation;
typedef enum  {
    StoreTypeNoType = 0,
    StoreTypeSuperama,
    StoreTypeWalmart,
    StoreTypeSamsClub,
    StoreTypeSuburbia,
    StoreTypeElPorton,
    StoreTypeAurrera,
    StoreTypeVips,
    StoreTypeUserLocation,
    StoreTypeCount,
}StoreType;

UIImage *images[StoreTypeCount];
@interface StoreAnnotation : NSObject <MKAnnotation> {
	// Callout properties
    StoreLocation *location;
    StoreType storeType;
    
	UIImageView *leftCalloutView;
}

@property (nonatomic, retain) StoreLocation *location;
@property (nonatomic, readonly, assign) StoreType storeType;
@property (nonatomic, readonly, retain) UIImageView *leftCalloutView;

- (id) initWithDictionary:(NSDictionary *)dict;
- (id) initWithStoreLocation:(StoreLocation *)location;
- (NSString*)getImageNameFromType;
- (NSString *)getTypeAsString;

+ (NSString*)getImageNameFromType:(StoreType)type;
+ (UIImage *)getImageFromType:(StoreType)type;
+ (StoreType)getTypeFromString:(NSString*)stringType;
+ (StoreType)getTypeFromLocationType:(NSInteger)type;
+ (NSString *)getStoreNameFromType:(StoreType)type;
+ (NSInteger)getLocationTypeFromStoreType:(StoreType)type;
- (void)updateLocation:(StoreLocation *)_location;
- (NSString*)getImageNameFromType;

@end
