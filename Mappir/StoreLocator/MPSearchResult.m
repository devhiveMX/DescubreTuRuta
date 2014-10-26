//
//  MPSearchResult.m
//  Mappir
//
//  Created by Leonardo Cid on 19/10/14.
//  Copyright (c) 2014 Devhive. All rights reserved.
//

#import "MPSearchResult.h"

@implementation MPSearchResult

- (id)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        [self initialize:dictionary];
    }
    return self;
}

- (void)initialize:(NSDictionary*)dictionary {
    NSArray *types = dictionary[@"type"];
    self.typeString = [types firstObject];
    self.resultName = dictionary[@"name"];
    NSDictionary *locationDict = dictionary[@"location"];
    self.location = CLLocationCoordinate2DMake([locationDict[@"lat"] floatValue], [locationDict[@"lng"] floatValue]);
    self.type = [self getResultFromString:self.typeString];
}

- (ResultType)getResultFromString:(NSString*)typeAsString {
    NSString *string = [typeAsString lowercaseString];
    if ([string isEqualToString:@"municipios"]) {
        return ResultMunicipality;
    } else if ([string isEqualToString:@"localidades rurales"]) {
        return ResultRuralCommunity;
    } else if ([string isEqualToString:@"colonias"]) {
        return ResultColony;
    } else if ([string isEqualToString:@"localidades urbanas"]) {
        return ResultUrbanCommunity;
    } else if ([string containsString:@"puntos de"] || [string containsString:@"lugares de"]) {
        return ResultPointOfInterest;
    }
    return ResultDefault;
}


@end
