//
//  ARGeoViewController.m
//  ARKitDemo
//
//  Created by Zac White on 8/2/09.
//  Copyright 2009 Zac White. All rights reserved.
//

#import "ARGeoViewController.h"

#import "ARGeoCoordinate.h"
#import "ARLocationView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ARGeoViewController
@synthesize userLocation;

@synthesize centerLocation;
@synthesize gpsParser;
@synthesize storesLocationsArray;

@synthesize locationViewDelegate;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!isDismissing)
        [self startListening];
#if DEBUG_MODE
    NSLog(@"Rect: %@", NSStringFromCGRect(self.view.frame));
#endif
}

- (void)setCenterLocation:(CLLocation *)newLocation {
	centerLocation = newLocation;
	
	for (ARGeoCoordinate *geoLocation in self.coordinates) {
		if ([geoLocation isKindOfClass:[ARGeoCoordinate class]]) {
			[geoLocation calibrateUsingOrigin:centerLocation];
			
			if (geoLocation.radialDistance > self.maximumScaleDistance) {
				self.maximumScaleDistance = geoLocation.radialDistance;
			}
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	centerLocation = newLocation ;
    for (ARGeoCoordinate *geoLocation in self.coordinates) {
		if ([geoLocation isKindOfClass:[ARGeoCoordinate class]]) {
			[geoLocation calibrateUsingOrigin:centerLocation];
			
			if (geoLocation.radialDistance > self.maximumScaleDistance) {
				self.maximumScaleDistance = geoLocation.radialDistance;
			}
		}
	}
	[super locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
}

- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate {
	
    //	CGRect theFrame = CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT);
    
    ARLocationView *locationView = (ARLocationView*)[[[NSBundle mainBundle] loadNibNamed:@"ARLocationView" owner:self options:nil] objectAtIndex:0];
    //	UIView *tempView = [[UIView alloc] initWithFrame:theFrame];
    //    [tempView setUserInteractionEnabled:YES];
	
    //	tempView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0.5 alpha:0.5];
	
	UILabel *titleLabel = locationView.titleLabel;
    //	titleLabel.backgroundColor = [UIColor colorWithWhite:.3 alpha:.8];
    //	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.text = coordinate.title;
    //	[titleLabel sizeToFit];
    //    titleLabel.tag = 1;
	
    //	titleLabel.frame = CGRectMake(BOX_WIDTH / 2.0 - titleLabel.frame.size.width / 2.0, 0, titleLabel.frame.size.width, titleLabel.frame.size.height);
    titleLabel.layer.cornerRadius = 5;
//    titleLabel.layer.borderColor = [UIColor blackColor].CGColor;
//    titleLabel.layer.borderWidth = 1.0;
    //	
	UIImageView *pointView = locationView.imageView;
    ARGeoCoordinate *geoCoordinate = (ARGeoCoordinate*)coordinate;
    switch (geoCoordinate.type) {
        case 1:
            pointView.image = [UIImage imageNamed:@"iconoWalmart.png"];
            titleLabel.textColor = [UIColor colorWithRed:0.0 green:0.49 blue:0.76 alpha:1.0];
            break;
        case 2:
            //            pointView.image = [UIImage imageNamed:@"indicador_superama.png"];
            pointView.image = [UIImage imageNamed:@"iconoSuperama.png"];
            
            break;
        case 3:
            pointView.image = [UIImage imageNamed:@"iconoSams.png"];
            titleLabel.textColor = [UIColor colorWithRed:0.39 green:0.62 blue:0.25 alpha:1.0];
            break;
    }
    
    //	pointView.frame = CGRectMake((int)(BOX_WIDTH / 2.0 - pointView.image.size.width / 2.0), (int)(BOX_HEIGHT / 2.0 - pointView.image.size.height / 2.0), pointView.image.size.width, pointView.image.size.height);
    pointView.tag = 2;
    //    locationView.actionButton.frame = pointView.frame;
    UILabel *label = locationView.distanceLabel;
    //    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((BOX_WIDTH -80) / 2, BOX_HEIGHT - 20, 80, 20)];    
    //    [label setTextAlignment:UITextAlignmentCenter];
    //    label.backgroundColor = [UIColor colorWithWhite:.3 alpha:.8];
    label.layer.cornerRadius = 5;    
//    label.layer.borderColor = [UIColor blackColor].CGColor;
//    label.layer.borderWidth = 1.0;
    if (geoCoordinate.distance > 500) {
        label.text = [NSString stringWithFormat:@"%.2f km",(geoCoordinate.distance/1000)];
    } else {
        label.text = [NSString stringWithFormat:@"%d m",(int)geoCoordinate.distance];
    }
    
    //    label.tag = 3;
    //    [tempView addSubview:label];
    //    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //    UIButton *button = locationView.actionButton;
    //    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //    [button setFrame:theFrame];
    //    [button setTag:5];
    //    button.backgroundColor = [UIColor colorWithRed:0.25 green:75 blue:0.1 alpha:0.5];
    //    [tempView addSubview:button];
    //    [tempView bringSubviewToFront:button];
    
    if (self.locationViewDelegate) {
        [locationView setDelegate:self.locationViewDelegate];
    } else {
        [locationView setDelegate:self];
    }
	
    //	[titleLabel release];
    //	[pointView release];
    //    [label release];
    return locationView;
    //	return [tempView autorelease];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)updateView:(UIView*)view withCoordinate:(ARCoordinate*)coordinate {
    ARLocationView *locationView = (ARLocationView*)view;
    UILabel *label = locationView.distanceLabel;
    ARGeoCoordinate *geoCoordinate = (ARGeoCoordinate*)coordinate;
    if (geoCoordinate.distance > 500) {
        label.text = [NSString stringWithFormat:@"%.2f km",(geoCoordinate.distance/1000)];
    } else {
        label.text = [NSString stringWithFormat:@"%d m",(int)geoCoordinate.distance];
    }
}

#pragma mark - GPSLocationsParserDelegate 

- (void)gpsLocationsParserDidFinishParse:(GPSLocationsParser*)parser {
    self.storesLocationsArray = [NSArray arrayWithArray:parser.results];
    self.gpsParser = nil;
}



@end
