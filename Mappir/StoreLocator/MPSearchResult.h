//
//  MPSearchResult.h
//  Mappir
//
//  Created by Leonardo Cid on 19/10/14.
//  Copyright (c) 2014 Devhive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    ResultDefault,
    ResultStreet,
    ResultColony,
    ResultMunicipality,
    ResultPointOfInterest,
    ResultRuralCommunity,
    ResultUrbanCommunity
}ResultType;


@interface MPSearchResult : NSObject
@property (nonatomic, strong) NSString *resultName;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSString *typeString;;
@property (nonatomic) ResultType type;

- (id)initWithDictionary:(NSDictionary*)dictionary;

@end
