//
//  ARKViewController.m
//  ARKitDemo
//
//  Created by Zac White on 8/1/09.
//  Copyright 2009 Zac White. All rights reserved.
//

#import "ARViewController.h"
#import "MKMapView+ZoomLevel.h"
#import <QuartzCore/QuartzCore.h>
//#import "TestAnnotation.h"
#import "ARGeoCoordinate.h"
#import "ARConstants.h"
#import "StoreAnnotation.h"
#import "ARLocationView.h"
#import "UIView+getFirstResponder.h"
#import "WBaseViewController.h"

NSComparisonResult LocationSortClosestFirst(ARCoordinate *s1, ARCoordinate *s2, void *ignore);

@implementation ARViewController

@synthesize locationManager, accelerometerManager;
@synthesize centerCoordinate;

@synthesize scaleViewsBasedOnDistance, rotateViewsBasedOnPerspective;
@synthesize maximumScaleDistance;
@synthesize minimumScaleFactor, maximumRotationAngle;

@synthesize updateFrequency;

@synthesize debugMode = ar_debugMode;

@synthesize coordinates = ar_coordinates;

@synthesize delegate, datasource, locationDelegate, accelerometerDelegate;

@synthesize cameraController;
@synthesize mapView;
@synthesize mapContainerView;
@synthesize useMapView;
@synthesize detailView;
@synthesize focusedView;

- (id)init {
	if (!(self = [super init])) return nil;
	
	ar_debugView = nil;
	ar_overlayView = nil;
	
	ar_debugMode = NO;
	
	ar_coordinates = [[NSMutableArray alloc] init];
	ar_coordinateViews = [[NSMutableArray alloc] init];
	
	_updateTimer = nil;
	self.updateFrequency = 1 / 20.0;
	
#if !TARGET_IPHONE_SIMULATOR
	
	self.cameraController = [[UIImagePickerController alloc] init];
	self.cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
	self.cameraController.delegate = self;
//	self.cameraController.cameraViewTransform = CGAffineTransformScale(self.cameraController.cameraViewTransform, 1.24299 ,1.24299 );
	
	self.cameraController.showsCameraControls = NO;
//	self.cameraController.navigationBarHidden = YES;
//    self.cameraController.wantsFullScreenLayout = YES;
#endif
	self.scaleViewsBasedOnDistance = YES;
	self.maximumScaleDistance = 1.0;
	self.minimumScaleFactor = 0.5;
	
	self.rotateViewsBasedOnPerspective = YES;
	self.maximumRotationAngle = M_PI / 6.0;
    isOpenMapRotating = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationWasFocused:) name:@"locationFocused" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detailButtonNotification:) name:@"detailViewButtonPressed" object:nil];
	
	self.wantsFullScreenLayout = NO;
	
	return self;
}

- (id)initWithLocationManager:(CLLocationManager *)manager {
	
	if (!(self = [super init])) return nil;
	
	//use the passed in location manager instead of ours.
	self.locationManager = manager;
	self.locationManager.delegate = self;
	
	self.locationDelegate = nil;
	
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	ar_overlayView = [[UIView alloc] initWithFrame:CGRectZero];
    
	if (self.debugMode) {
		ar_debugView = [[UILabel alloc] initWithFrame:CGRectZero];
		ar_debugView.textAlignment = UITextAlignmentCenter;
		ar_debugView.text = @"Waiting...";
		
		[ar_overlayView addSubview:ar_debugView];
	}
		
	self.view = ar_overlayView;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setCancelsTouchesInView:NO];
    [ar_overlayView addGestureRecognizer:tapRecognizer];

}

- (void)setUpdateFrequency:(double)newUpdateFrequency {
	
	updateFrequency = newUpdateFrequency;
	
	if (!_updateTimer) return;
	
	[_updateTimer invalidate];
	
	_updateTimer = [NSTimer scheduledTimerWithTimeInterval:self.updateFrequency
													 target:self
												   selector:@selector(updateLocations:)
												   userInfo:nil
													repeats:YES];
}

- (void)setDebugMode:(BOOL)flag {
	if (self.debugMode == flag) return;
	
	ar_debugMode = flag;
	
	//we don't need to update the view.
	if (![self isViewLoaded]) return;
	
	if (self.debugMode) [ar_overlayView addSubview:ar_debugView];
	else [ar_debugView removeFromSuperview];
}

- (BOOL)viewportContainsCoordinate:(ARCoordinate *)coordinate {
	double centerAzimuth = self.centerCoordinate.azimuth;
	double leftAzimuth = centerAzimuth - VIEWPORT_WIDTH_RADIANS / 0.5;
	
	if (leftAzimuth < 0.0) {
		leftAzimuth = 2 * M_PI + leftAzimuth;
	}
	
	double rightAzimuth = centerAzimuth + VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (rightAzimuth > 2 * M_PI) {
		rightAzimuth = rightAzimuth - 2 * M_PI;
	}
	
	BOOL result = (coordinate.azimuth > leftAzimuth && coordinate.azimuth < rightAzimuth);
	
	if(leftAzimuth > rightAzimuth) {
		result = (coordinate.azimuth < rightAzimuth || coordinate.azimuth > leftAzimuth);
	}
	
	double centerInclination = self.centerCoordinate.inclination;
	double bottomInclination = centerInclination - VIEWPORT_HEIGHT_RADIANS / 2.0;
	double topInclination = centerInclination + VIEWPORT_HEIGHT_RADIANS / 2.0;
	
	//check the height.
	result = result && (coordinate.inclination > bottomInclination && coordinate.inclination < topInclination);
	
	//NSLog(@"coordinate: %@ result: %@", coordinate, result?@"YES":@"NO");
	
	return result;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
	return YES;
}
- (void)startListening {
	
	//start our heading readings and our accelerometer readings.
	
	if (!self.locationManager) {
		self.locationManager = [[CLLocationManager alloc] init];
		
		//we want every move.
		self.locationManager.headingFilter = kCLHeadingFilterNone;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];		
		[self.locationManager startUpdatingHeading];
	}
	
	//steal back the delegate.
	self.locationManager.delegate = self;
	
	if (!self.accelerometerManager) {
		self.accelerometerManager = [UIAccelerometer sharedAccelerometer];
		self.accelerometerManager.updateInterval = 0.01;
		self.accelerometerManager.delegate = self;
	}
	
	if (!self.centerCoordinate) {
		self.centerCoordinate = [ARCoordinate coordinateWithRadialDistance:0 inclination:0 azimuth:0];
	}
}

- (void)stopListening {
	
	//start our heading readings and our accelerometer readings.
	
	[self.locationManager setDelegate:nil];
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    [self.accelerometerManager setDelegate:nil];
    self.accelerometerManager = nil;
	
}

- (CGPoint)pointInView:(UIView *)realityView forCoordinate:(ARCoordinate *)coordinate {
	
	CGPoint point;
	
	//x coordinate.
	
	double pointAzimuth = coordinate.azimuth;
	
	//our x numbers are left based.
	double leftAzimuth = self.centerCoordinate.azimuth - VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (leftAzimuth < 0.0) {
		leftAzimuth = 2 * M_PI + leftAzimuth;
	}
	
	if (pointAzimuth < leftAzimuth) {
		//it's past the 0 point.
		point.x = ((2 * M_PI - leftAzimuth + pointAzimuth) / VIEWPORT_WIDTH_RADIANS) * realityView.frame.size.width;
	} else {
		point.x = ((pointAzimuth - leftAzimuth) / VIEWPORT_WIDTH_RADIANS) * realityView.frame.size.width;
	}
	
	//y coordinate.
	
	double pointInclination = coordinate.inclination;
	
	double topInclination = self.centerCoordinate.inclination - VIEWPORT_HEIGHT_RADIANS / 2.0;
	
	point.y = realityView.frame.size.height - ((pointInclination - topInclination) / VIEWPORT_HEIGHT_RADIANS) * realityView.frame.size.height;
	
	return point;
}

#define kFilteringFactor 0.05
UIAccelerationValue rollingX, rollingZ;

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	// -1 face down.
	// 1 face up.
	
	//update the center coordinate.
	
//	NSLog(@"x: %f y: %f z: %f", acceleration.x, acceleration.y, acceleration.z);
	
	//this should be different based on orientation.
	
	rollingZ  = (acceleration.z * kFilteringFactor) + (rollingZ  * (1.0 - kFilteringFactor));
    rollingX = (acceleration.y * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
	
	if (rollingZ > 0.0) {
		self.centerCoordinate.inclination = atan(rollingX / rollingZ) + M_PI / 2.0;
	} else if (rollingZ < 0.0) {
		self.centerCoordinate.inclination = atan(rollingX / rollingZ) - M_PI / 2.0;// + M_PI;
	} else if (rollingX < 0) {
		self.centerCoordinate.inclination = M_PI/2.0;
	} else if (rollingX >= 0) {
		self.centerCoordinate.inclination = 3 * M_PI/2.0;
	}
	if (!transitioningBetweenStates) {
        if (fabs(acceleration.y) < .7 && acceleration.z < -0.65) {
            if (!horizontalMode) {
                horizontalMode = YES;
                rotatingMap = NO;
                [self rotateMapWithAngle:0];
                self.mapContainerView.userInteractionEnabled = YES;
                transitioningBetweenStates= YES;
//                if (lastOpenMapZoom != 0) {
//                    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate zoomLevel:lastOpenMapZoom animated:YES];
//                }
                lastOpenMapRegion.center = mapView.userLocation.coordinate;
                if (lastOpenMapRegion.span.latitudeDelta != 0 && lastOpenMapRegion.span.longitudeDelta != 0) {
                    [self.mapView setRegion:lastOpenMapRegion animated:YES];
                }
                [self.mapView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
                [UIView beginAnimations:@"animationOpenMap1" context:nil];
                [UIView setAnimationDelegate:self];
                [UIView commitAnimations];
            }
        } else {
            if (horizontalMode) {
                self.mapContainerView.userInteractionEnabled = NO;
                transitioningBetweenStates = YES;
                horizontalMode = NO;
                lastOpenMapRegion = mapView.region;
                if (isOpenMapRotating) {
                    rotatingMap = NO;
                    [self rotateMapWithAngle:0];
                }
                
                lastOpenMapZoom = [mapView getZoom];
                lastOpenMapRegion = [mapView region];
                [UIView beginAnimations:@"animationCloseMap" context:nil];
                self.mapContainerView.frame = MAP_CONTAINER_CLOSE_RECT;
                [UIView setAnimationDelegate:self];
                self.mapContainerView.layer.cornerRadius = 40;
                [UIView commitAnimations];

            }
        }
    }
    
	if (self.accelerometerDelegate && [self.accelerometerDelegate respondsToSelector:@selector(accelerometer:didAccelerate:)]) {
		//forward the acceleromter.
		[self.accelerometerDelegate accelerometer:accelerometer didAccelerate:acceleration];
	}
}

NSComparisonResult LocationSortClosestFirst(ARCoordinate *s1, ARCoordinate *s2, void *ignore) {
    if (s1.radialDistance < s2.radialDistance) {
		return NSOrderedAscending;
	} else if (s1.radialDistance > s2.radialDistance) {
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}

- (void)addAnnotations:(NSArray*)annotationsArray {
    if (!annotations) {
        annotations = [NSMutableArray array];
    }
    for (id<MKAnnotation> annotation in annotationsArray) {
        if ([annotations indexOfObject:annotation] == NSNotFound) {
            [annotations addObject:annotation];
        }
        if ([[mapView annotations] indexOfObject:annotation] == NSNotFound) {
            [mapView addAnnotation:annotation];
        }
    }
}


- (void)addAnnotation:(id<MKAnnotation>)annotation {
    if (!annotations) {
        annotations = [NSMutableArray array];
    }
    if ([annotations indexOfObject:annotation] == NSNotFound) {
        [annotations addObject:annotation];
        [mapView addAnnotation:annotation];
    }
}

- (void)removeAnnotations:(NSArray *)annotationsArray {
    [annotations removeObjectsInArray:annotationsArray];
    [mapView removeAnnotations:annotationsArray];
}

- (void)removeAnnotation:(id<MKAnnotation>)annotation {
    [annotations removeObject:annotation];
    [mapView removeAnnotation:annotation];
}

- (void)addCoordinate:(ARCoordinate *)coordinate {
	[self addCoordinate:coordinate animated:YES];
}

- (void)addCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated {
	//do some kind of animation?
	[ar_coordinates addObject:coordinate];
		
	if (coordinate.radialDistance > self.maximumScaleDistance) {
		self.maximumScaleDistance = coordinate.radialDistance;
	}
//    NSString *title = [NSString stringWithFormat:@"Annotation %d", [ar_coordinateViews count] + 1];
//    NSString *subtitle = [NSString stringWithFormat:@"Subtitle %d", [ar_coordinateViews count] + 1];
    
//    ARGeoCoordinate *geocoordinate = (ARGeoCoordinate*)coordinate;
//    TestAnnotation *annotation = [[TestAnnotation alloc] initWithTitle:title subtitle:subtitle coordinate:geocoordinate.geoLocation.coordinate];
//    annotation.type = geocoordinate.type;
//    [self addAnnotation:annotation];
    
	//message the delegate.
	[ar_coordinateViews addObject:[self.datasource viewForCoordinate:coordinate]];
}

- (void)addCoordinates:(NSArray *)newCoordinates {
	
	//go through and add each coordinate.
	for (ARCoordinate *coordinate in newCoordinates) {
		[self addCoordinate:coordinate animated:NO];
	}
}

- (void)updateCoordinates:(NSArray*)newCoordinates {
    [self.focusedView setValue:[NSNumber numberWithBool: NO] forKey:@"highlighted"];
    self.focusedView = nil;
    [self dismissDetailView];
    [ar_coordinates removeAllObjects];
    [ar_coordinateViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [ar_coordinateViews removeAllObjects];

    [self addCoordinates:newCoordinates];
}

- (void)removeCoordinate:(ARCoordinate *)coordinate {
	[self removeCoordinate:coordinate animated:YES];
}

- (void)removeCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated {
	//do some kind of animation?
	[ar_coordinates removeObject:coordinate];
}

- (void)removeCoordinates:(NSArray *)coordinates {	
	for (ARCoordinate *coordinateToRemove in coordinates) {
		NSUInteger indexToRemove = [ar_coordinates indexOfObject:coordinateToRemove];
		
		//TODO: Error checking in here.
		
		[ar_coordinates removeObjectAtIndex:indexToRemove];
		[ar_coordinateViews removeObjectAtIndex:indexToRemove];
	}
}

- (void)updateLocations{
	//update locations!
	
	if (!ar_coordinateViews || ar_coordinateViews.count == 0) {
		return;
	}
	
	ar_debugView.text = [self.centerCoordinate description];
	
	int index = 0;
	for (ARCoordinate *item in ar_coordinates) {
		
		UIView *viewToDraw = [ar_coordinateViews objectAtIndex:index];
		
		if ([self viewportContainsCoordinate:item]) {
			
            if ([delegate respondsToSelector:@selector(updateView:withCoordinate:)]) {
                [delegate updateView:viewToDraw withCoordinate:item];
            }
            
			CGPoint loc = [self pointInView:ar_overlayView forCoordinate:item];
			
			CGFloat scaleFactor = 1.0;
//			if (self.scaleViewsBasedOnDistance) 
            {
				scaleFactor = 1.0 - self.minimumScaleFactor * (item.radialDistance / self.maximumScaleDistance);
			}
			
            if ([viewToDraw isKindOfClass:[ARLocationView class]]) {
                [(ARLocationView*)viewToDraw setCurrentScaleFactor:scaleFactor];
            }
            
//			float width = viewToDraw.bounds.size.width * scaleFactor;
//			float height = viewToDraw.bounds.size.height * scaleFactor;

//            float width = BOX_WIDTH * scaleFactor;
//			float height = BOX_HEIGHT * scaleFactor;
			
            
//            viewToDraw.center = CGPointMake(loc.x - width / 2.0, loc.y - height / 2.0);
//			viewToDraw.frame = CGRectMake(loc.x - width / 2.0, loc.y - height / 2.0, BOX_WIDTH, BOX_HEIGHT);
            viewToDraw.center = CGPointMake(loc.x, loc.y);
						
			CATransform3D transform = CATransform3DIdentity;
			
			//set the scale if it needs it.
//			if (self.scaleViewsBasedOnDistance) 
            {
				//scale the perspective transform if we have one.
                if (![[viewToDraw valueForKey:@"highlighted"] boolValue])
                    transform = CATransform3DScale(transform, scaleFactor, scaleFactor, scaleFactor);
			}
			
			if (self.rotateViewsBasedOnPerspective) {
				transform.m34 = 1.0 / 300.0;
				
				double itemAzimuth = item.azimuth;
				double centerAzimuth = self.centerCoordinate.azimuth;
				if (itemAzimuth - centerAzimuth > M_PI) centerAzimuth += 2*M_PI;
				if (itemAzimuth - centerAzimuth < -M_PI) itemAzimuth += 2*M_PI;
				
				double angleDifference = itemAzimuth - centerAzimuth;
				transform = CATransform3DRotate(transform, self.maximumRotationAngle * angleDifference / (VIEWPORT_HEIGHT_RADIANS / 2.0) , 0, 1, 0);
			}
            NSNumber *animating = [viewToDraw valueForKey:@"isAnimating"];
			if (animating) {
                if (![animating boolValue]) {
                    viewToDraw.layer.transform = transform;
                }
            } else {
                
            }
			
			//if we don't have a superview, set it up.
			if (!(viewToDraw.superview)) {
				[ar_overlayView addSubview:viewToDraw];
				[ar_overlayView sendSubviewToBack:viewToDraw];
			}
			
		} else {
			[viewToDraw removeFromSuperview];
			viewToDraw.transform = CGAffineTransformIdentity;
		}
		index++;
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
		
//	self.centerCoordinate.azimuth = fmod(newHeading.magneticHeading, 360.0) * (2 * (M_PI / 360.0));
    self.centerCoordinate.azimuth = degreesToRadian(newHeading.magneticHeading);
    if ((!horizontalMode && rotatingMap) || (isOpenMapRotating && rotatingMap)) {
        CGFloat angleToRotate = (-1 * newHeading.magneticHeading * M_PI / 180);
        [self rotateMapWithAngle:angleToRotate];
        
    }
    [self updateLocations];
	if (self.locationDelegate && [self.locationDelegate respondsToSelector:@selector(locationManager:didUpdateHeading:)]) {
		//forward the call.
		[self.locationDelegate locationManager:manager didUpdateHeading:newHeading];
	}
    
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	
	if (self.locationDelegate && [self.locationDelegate respondsToSelector:@selector(locationManagerShouldDisplayHeadingCalibration:)]) {
		//forward the call.
		return [self.locationDelegate locationManagerShouldDisplayHeadingCalibration:manager];
	}
	
	return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if (self.locationDelegate && [self.locationDelegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
		//forward the call.
		[self.locationDelegate locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
	}
    if (!horizontalMode) {
        [self.mapView setCenterCoordinate:newLocation.coordinate zoomLevel:16 animated:YES];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if (self.locationDelegate && [self.locationDelegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
		//forward the call.
		return [self.locationDelegate locationManager:manager didFailWithError:error];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    if (isDismissing) {
        [super viewDidAppear:animated];
        return;
    }
#if !TARGET_IPHONE_SIMULATOR
	[self.cameraController setCameraOverlayView:ar_overlayView];
    
	[self presentModalViewController:self.cameraController animated:NO];
    
    CGRect cameraFrame = CGRectZero;
    CGRect arOverlayViewFrame = CGRectZero;
    if ([WBaseViewController deviceModelName] == DeviceiPhone5) {
        cameraFrame = CGRectMake(0, 0, 320, 576);
        self.view.frame = CGRectMake(0, 0, 320, 480);
        arOverlayViewFrame = self.view.frame;
    } else {
        cameraFrame = CGRectMake(0, 0, 320, 392);
        self.view.frame = CGRectMake(0, 0, 320, 392);
        arOverlayViewFrame = cameraFrame;
    }
    
    self.cameraController.showsCameraControls = NO;
	self.cameraController.view.frame = cameraFrame;
    self.cameraController.view.bounds = cameraFrame;
    [self.view setClipsToBounds:YES];
    //[ar_overlayView setBackgroundColor:[UIColor colorWithRed:0.2 green:0.5 blue:0.1 alpha:0.4]];
	[ar_overlayView setFrame:arOverlayViewFrame];
    

    detailView = [[[NSBundle mainBundle] loadNibNamed:@"ARDetailView" owner:self options:nil] objectAtIndex:0];
    CGRect frame = detailView.frame;
    frame.origin.y = self.view.frame.size.height - frame.size.height - 10;
    frame.origin.x = (cameraFrame.size.width - frame.size.width) / 2;
    detailView.frame = frame;
    [self.detailView setVisibleWithFadeAnimation:NO duration:0];
    [ar_overlayView addSubview:detailView];

#endif
    
//	if (!_updateTimer) {
//		_updateTimer = [[NSTimer scheduledTimerWithTimeInterval:self.updateFrequency
//													 target:self
//												   selector:@selector(updateLocations:)
//												   userInfo:nil
//													repeats:YES] retain];
//	}
	if (self.useMapView) {
        self.mapView = [[MKMapView alloc] initWithFrame:MAP_CLOSE_RECT];
        //    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(210, 370, 80, 80)];
        //    [self.mapView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
        [self.mapContainerView setAutoresizingMask:UIViewAutoresizingNone];
        self.mapView.showsUserLocation = YES;
        self.mapView.delegate = self;
        //    self.mapView.layer.masksToBounds = YES;
        self.mapView.userInteractionEnabled = NO;
        
        
        self.mapContainerView = [[UIView alloc] initWithFrame:MAP_CONTAINER_CLOSE_RECT];
        [mapContainerView setClipsToBounds:YES];
        [mapContainerView addSubview:mapView];
        mapContainerView.layer.cornerRadius = 40;
        rotatingMap = YES;
        //    mapContainerView.layer.masksToBounds = YES;
        //    [mapContainerView setBackgroundColor:[UIColor blueColor]];
        
        //    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        //        [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
        //    }
        
        
        //    [ar_overlayView addSubview:mapView];
        [ar_overlayView addSubview:mapContainerView];
        
        [mapView addAnnotations:annotations];
    }
    if ([delegate respondsToSelector:@selector(arViewControllerReady:)]) {
        [delegate arViewControllerReady:self];
    }
	[super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.debugMode) {
		[ar_debugView sizeToFit];
		[ar_debugView setFrame:CGRectMake(0,
										  ar_overlayView.frame.size.height - ar_debugView.frame.size.height,
										  ar_overlayView.frame.size.width,
										  ar_debugView.frame.size.height)];
	}
	
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"detailViewButtonPressed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"locationFocused" object:nil];
    self.detailView = nil;
    
    [self.locationManager setDelegate:nil];
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    [self.accelerometerManager setDelegate:nil];
    self.accelerometerManager = nil;
    
    [ar_overlayView removeGestureRecognizer:tapRecognizer];
	ar_overlayView = nil;

	
}

#pragma mark - IBActions

- (void)handleTap:(UIGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:sender.view];
#if DEBUG_MODE
    NSLog(@"Handle Tap triggered %@", sender);
#endif
    if (!([self isPointInARViews:touchPoint] || CGRectContainsPoint(self.detailView.frame, touchPoint))) {
        
        [self dismissDetailView];
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        if (firstTime) {
            [aMapView setCenterCoordinate:userLocation.coordinate zoomLevel:16 animated:YES];
            firstTime = NO;
        }
        else{
            if (!horizontalMode)
                [aMapView setCenterCoordinate:userLocation.coordinate animated:YES];
        }
    }
}

- (UIView*)mapView:(MKMapView*)aMapView viewForAnnotation:(id<MKAnnotation>)annotation {
#if USE_SUPERAMA_LOCATIONS
NSString *identifier = nil;
MKAnnotationView *annotationView = nil;
if ([annotation isKindOfClass:[MKUserLocation class]]) {
#if USE_CUSTOM_USER_LOCATION
    MKUserLocation *anAnnotation = (MKUserLocation *)annotation;
    [anAnnotation setTitle:@"Mi ubicación"];
    if ([self.addressLabel.text length] > 0) 
    {   
        [anAnnotation setSubtitle:self.addressLabel.text];
    }
    identifier =  [NSString stringWithFormat:@"UserLocation"];
    
    annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!annotationView) {
        annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
        
        //[annotationView setImage:[self getImageFromName:[storeAnnotation getImageNameFromType]]];
        [annotationView setCalloutOffset:CGPointMake(-1.2, 0)];
        [annotationView setCanShowCallout:YES];
        
        UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //[disclosureButton setImage:[UIImage imageNamed:@"redDisclosure"] forState:UIControlStateNormal];
        [disclosureButton setFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
        [annotationView setAnnotation:annotation];
        UIImage *image = [UIImage imageNamed:@"indicador_usuario"];
        [annotationView setImage:image];
        
        CGRect frame =  CGRectMake(0, - (image.size.height), image.size.width, image.size.height);
        [annotationView setFrame:frame];
        [annotationView setAnnotation:annotation];
    }
    
    
    //annotationView.alpha = 0;
    
    
    return annotationView;
#else
    return nil;
#endif
}

if ([annotation isKindOfClass:[StoreAnnotation class]]) {
    StoreAnnotation *storeAnnotation = (StoreAnnotation *)annotation;
    identifier = [NSString stringWithFormat:@"StoreAnnotationView"];
    
    annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        //[annotationView setImage:[self getImageFromName:[storeAnnotation getImageNameFromType]]];
        [annotationView setCalloutOffset:CGPointMake(-1.2, 0)];
        [annotationView setCanShowCallout:YES];
        
        UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //[disclosureButton setImage:[UIImage imageNamed:@"redDisclosure"] forState:UIControlStateNormal];
        [disclosureButton setFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
        [disclosureButton addTarget:self action:@selector(disclosureButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [annotationView setRightCalloutAccessoryView:disclosureButton];
    }
    {
        [annotationView setAnnotation:annotation];
        UIImage *image = [self getImageFromName:[storeAnnotation getImageNameFromType]];
        [annotationView setImage:image];
        CGRect frame =  CGRectMake(0, -image.size.height, image.size.width, image.size.height);
        NSLog(@"%@", NSStringFromCGRect(frame));
        [annotationView setFrame:frame];
    }
    //annotationView.alpha = 0;
    [annotationView setTransform:CGAffineTransformMakeScale(0.01, 0.01)];
    
    [annotationView setLeftCalloutAccessoryView:(UIView *)storeAnnotation.leftCalloutView];
    
    return annotationView;
} 
#if USE_DIRECTIONS
else if ([annotation isKindOfClass:[DirectionAnnotation class]]){ 
    identifier = [NSString stringWithFormat:@"DirectionAnnotationView"];
    annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView) {
        annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
        /*if ([[[dirAnnotation dictionary] objectForKey:@"selected"] boolValue])
         {
         [annotationView setPinColor:MKPinAnnotationColorPurple];
         } else {
         [annotationView setPinColor:MKPinAnnotationColorRed];
         }*/
        
        //annotationView.animatesDrop = YES;
        //[annotationView setImage:[self getImageFromName:[storeAnnotation getImageNameFromType]]];
        //[annotationView setCalloutOffset:CGPointMake(-1.2, 0)];
        [annotationView setCanShowCallout:YES];
    }
    [annotationView setTag:66];
    [annotationView setAnnotation:annotation];
    
} 
#endif
else {
    
    NSString *identifier = [NSString stringWithFormat:@"UserAnnotationView"];
    
    MKAnnotationView *annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.image = [UIImage imageNamed:@"btnUser_barraDetalle.png"];
        //[annotationView setImage:[self getImageFromName:[storeAnnotation getImageNameFromType]]];
        [annotationView setCalloutOffset:CGPointMake(-1.2, 0)];
        //[annotationView setCanShowCallout:YES];
        
        /*UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
         //[disclosureButton setImage:[UIImage imageNamed:@"redDisclosure"] forState:UIControlStateNormal];
         [disclosureButton setFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
         [disclosureButton addTarget:self action:@selector(disclosureButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
         [annotationView setRightCalloutAccessoryView:disclosureButton];*/
    }
    
}

return nil;
#else
    MKAnnotationView *annotationView = nil; 
    if ([annotation isKindOfClass:[TestAnnotation class]]) {
        NSString *identifier = [NSString stringWithFormat:@"DirectionAnnotationView"];
         annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!annotationView) {
            annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
            [annotationView setCanShowCallout:YES];
        }
            
        MKPinAnnotationView *pinannotationview = (MKPinAnnotationView*)annotationView;
        switch (((TestAnnotation*)annotation).type) {
            case 1:
                pinannotationview.pinColor = MKPinAnnotationColorPurple;
                break;
            case 2:
                pinannotationview.pinColor = MKPinAnnotationColorRed;
                break;
            case 3:
                pinannotationview.pinColor = MKPinAnnotationColorGreen;
                break;
            default:
                break;
        }
        [annotationView setTag:66];
        [annotationView setAnnotation:annotation];
    }
    return annotationView;

#endif
}

- (void)rotateMapWithAngle:(CGFloat)angle {
    
    [self.mapView setTransform:CGAffineTransformMakeRotation(angle)];
    
    for (id<MKAnnotation> annotation in mapView.annotations) 
    {
        MKAnnotationView* annotationView = [mapView viewForAnnotation:annotation];
        [annotationView setTransform:CGAffineTransformMakeRotation(-angle)];
    }
    
}

#pragma mark - Animation

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:@"animationOpenMap1"]) {
        [UIView beginAnimations:@"animationOpenMap2" context:nil];
        [UIView setAnimationDelegate:self];
        self.mapContainerView.frame = MAP_CONTAINER_OPEN_RECT;
        self.mapContainerView.layer.cornerRadius = 0;
        [UIView commitAnimations];
    } else if ([animationID isEqualToString:@"animationOpenMap2"]){
//        if (!CGRectEqualToRect(CGRectMake(0, 0, 320, 480), self.mapView.frame)) {
            [UIView beginAnimations:@"animationOpenMap3" context:nil];
            [UIView setAnimationDelegate:self];
            if (isOpenMapRotating)
            {
                self.mapView.frame = MAP_ROT_OPEN_RECT;
            } else {
                self.mapView.frame = MAP_OPEN_RECT;
            }   
            self.mapView.layer.cornerRadius = 0;
            [UIView commitAnimations];
//        } else {
//            transitioningBetweenStates = NO;
//        }
    } else if ([animationID isEqualToString:@"animationOpenMap3"]) {
        transitioningBetweenStates = NO;
        rotatingMap = isOpenMapRotating; 
    } else if ([animationID isEqualToString:@"animationCloseMap"]) {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate zoomLevel:16 animated:YES];

//        if (!CGRectEqualToRect(CGRectMake(0, 0, 80, 80), self.mapView.frame)) {
            [UIView beginAnimations:@"animationCloseMap2" context:nil];
            [UIView setAnimationDelegate:self];
            self.mapView.frame = MAP_CLOSE_RECT;
            [UIView commitAnimations];
//        } else {
//            rotatingMap = YES;
//            transitioningBetweenStates = NO;
//        }
    } else if ([animationID isEqualToString:@"animationCloseMap2"]) {
        if (isOpenMapRotating) {
            [UIView beginAnimations:@"animationCloseMap3" context:nil];
            [UIView setAnimationDelegate:self];
            self.mapView.frame = MAP_CLOSE_RECT;
            [UIView commitAnimations];
        } else {
            rotatingMap = YES;
            transitioningBetweenStates = NO;
        }
    } else if ([animationID isEqualToString:@"animationCloseMap3"]) {
        rotatingMap = YES;
        transitioningBetweenStates = NO;
    }
}

- (void)locationWasFocused:(NSNotification*)notification {
//    NSLog(@"Notification received from LocationView");
    ARLocationView *highLocationView = notification.object;
    int index = 0;
    int i = 0;
    for (UIView *view in ar_coordinateViews) {
        ARLocationView* locationView = (ARLocationView*)view;
        locationView.highlighted = (highLocationView == locationView);
        if (highLocationView == locationView)
            index = i;
        i++;
    }
    self.focusedView = highLocationView;
    ARCoordinate *coordinate = [ar_coordinates objectAtIndex:index];
    if (self.detailView && [self.delegate respondsToSelector:@selector(setDetailViewInfo:forCoordinate:)]) {
        [self.delegate setDetailViewInfo:self.detailView forCoordinate:coordinate];
    }
    [self.detailView setVisibleWithFadeAnimation:YES duration:0.20];
    
}

- (void)detailButtonNotification:(NSNotification*)notification {
    UIButton *button = notification.object;
    if ([delegate respondsToSelector:@selector(detailView:buttonPressed:)]) {
        [delegate detailView:detailView buttonPressed:button];
    }
}

- (void)dismissDetailView {
    [self.detailView setVisibleWithFadeAnimation:NO duration:0.20];
    [self.focusedView setValue:[NSNumber numberWithBool: NO] forKey:@"highlighted"];
    self.focusedView = nil;
    [[self.detailView valueForKey:@"titleLabel"] setText:@""];
    [[self.detailView valueForKey:@"detailLabel"] setText:@""];
    [[self.detailView valueForKey:@"imageView"] setImage:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
}

- (void)dismissCamera {
    [self stopListening];
    isDismissing = YES;
    [self.cameraController dismissModalViewControllerAnimated:NO];

}

- (BOOL)isPointInARViews:(CGPoint)point {
    for (UIView *arView in ar_coordinateViews) {
        if (CGRectContainsPoint(arView.frame, point)) {
            return YES;
        }
    }
    return NO;
}
@end
