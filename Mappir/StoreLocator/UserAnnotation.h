//
//  UserAnnotation.h
//  WalmartApp
//
//  Created by WALMEX3.0_1_WALMART on 04/10/11.
//  Copyright 2011 Walmart Stores Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface UserAnnotation : NSObject <MKAnnotation>
{
    UIImageView *leftCalloutView;
    CLLocationCoordinate2D coordinate;
    NSString *currentAddress;
    
}

@property (nonatomic,readonly) UIImageView *leftCalloutView;

@end
