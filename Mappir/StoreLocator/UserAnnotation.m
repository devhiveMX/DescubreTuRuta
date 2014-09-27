//
//  UserAnnotation.m
//  WalmartApp
//
//  Created by WALMEX3.0_1_WALMART on 04/10/11.
//  Copyright 2011 Walmart Stores Inc. All rights reserved.
//

#import "UserAnnotation.h"

@implementation UserAnnotation 
@synthesize leftCalloutView;
@synthesize coordinate;


- (id)initWithCurrentAddress:(NSString*)address coordinate:(CLLocationCoordinate2D)location {
    self = [super init];
    if (self) {
        currentAddress = address;
        [self setCoordinate: location];
    }
    return self;
}

- (void)dealloc {
}

- (NSString*)title {
    return @"Ubicación actual";
}

- (NSString*)subtitle {
    return currentAddress;
}
@end
