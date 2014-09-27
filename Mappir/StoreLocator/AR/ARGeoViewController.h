//
//  ARGeoViewController.h
//  ARKitDemo
//
//  Created by Zac White on 8/2/09.
//  Copyright 2009 Zac White. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ARViewController.h"
#import "GPSLocationsParser.h"
#import "ARLocationView.h"

@interface ARGeoViewController : ARViewController <ARViewDelegate, GPSLocationsParserDelegate, ARLocationViewDelegate> {
	CLLocation *centerLocation;
    
}

@property (nonatomic, assign) id <ARLocationViewDelegate> locationViewDelegate;
@property (nonatomic, retain) CLLocation *centerLocation;
@property (nonatomic, retain) GPSLocationsParser *gpsParser;
@property (nonatomic, retain) NSArray *storesLocationsArray;
@property (nonatomic, assign) CLLocationCoordinate2D userLocation;
@end
