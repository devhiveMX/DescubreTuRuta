//
//  SLRoutePoint.h
//  WalmartApp
//
//  Created by WALMEX3.0 _1 WALMART on 02/12/11.
//  Copyright (c) 2011 Walmart Stores Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>

@interface SLRoute : NSObject{
    MKMapPoint *points;
    NSInteger count;
}

@property (nonatomic, readonly) MKMapPoint *points;
@property (nonatomic, readonly) NSInteger count;

- (id)initWithPoints:(MKMapPoint*)_points count:(NSInteger)_count;
+(SLRoute*)routeWithPoints:(MKMapPoint*)points count:(NSInteger)count;


@end
