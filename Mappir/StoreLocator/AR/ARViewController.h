//
//  ARKViewController.h
//  ARKitDemo
//
//  Created by Zac White on 8/1/09.
//  Copyright 2009 Zac White. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "ARCoordinate.h"
#import "ARDetailView.h"
#define USE_SUPERAMA_LOCATIONS 1
#define USE_CUSTOM_USER_LOCATION 0

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define kFilteringFactor 0.05
#define degreesToRadian(x) (M_PI * (x) / 180.0)
#define radianToDegrees(x) ((x) * 180.0/M_PI)

@class ARViewController;
@protocol ARViewDelegate <NSObject>
@optional
- (void)arViewControllerReady:(ARViewController*)viewController;
- (void)updateView:(UIView*)view withCoordinate:(ARCoordinate*)coordinate;
- (void)setDetailViewInfo:(UIView*)detailView forCoordinate:(ARCoordinate*)coordinate;
- (void)detailView:(UIView*)detailView buttonPressed:(UIButton*)button;
@end

@protocol ARViewDataSource <NSObject>
- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate;
@end


@interface ARViewController : UIViewController <UIAccelerometerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	CLLocationManager *locationManager;
	UIAccelerometer *accelerometerManager;
	
	ARCoordinate *centerCoordinate;
	
	UIImagePickerController *cameraController;
	
	__unsafe_unretained id<ARViewDelegate> delegate;
	__unsafe_unretained id<ARViewDataSource> datasource;
	__unsafe_unretained id<CLLocationManagerDelegate> locationDelegate;
	__unsafe_unretained id<UIAccelerometerDelegate> accelerometerDelegate;
	
	BOOL scaleViewsBasedOnDistance;
	double maximumScaleDistance;
	double minimumScaleFactor;
	
	//defaults to 20hz;
	double updateFrequency;
	
	BOOL rotateViewsBasedOnPerspective;
    BOOL firstTime;
	double maximumRotationAngle;
	
@private
	BOOL ar_debugMode;
	
	NSTimer *_updateTimer;
	
	UIView *ar_overlayView;
	
	UILabel *ar_debugView;
	
	NSMutableArray *ar_coordinates;
	NSMutableArray *ar_coordinateViews;
    
    
    BOOL horizontalMode;
    BOOL rotatingMap;
    BOOL transitioningBetweenStates;
    NSMutableArray *annotations;
    
    BOOL isOpenMapRotating;
    float lastOpenMapZoom;
    MKCoordinateRegion lastOpenMapRegion;
    
    @public
    BOOL isDismissing;
    
    UITapGestureRecognizer *tapRecognizer;
}

@property (readonly) NSArray *coordinates;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UIView *mapContainerView;
@property (nonatomic, assign) UIView *focusedView;
@property (nonatomic) BOOL debugMode;

@property BOOL scaleViewsBasedOnDistance;
@property double maximumScaleDistance;
@property double minimumScaleFactor;

@property BOOL rotateViewsBasedOnPerspective;
@property double maximumRotationAngle;

@property (nonatomic) double updateFrequency;
@property BOOL useMapView;
@property (nonatomic, retain) UIView *detailView;


//adding coordinates to the underlying data model.
- (void)addCoordinate:(ARCoordinate *)coordinate;
- (void)addCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated;

- (void)addCoordinates:(NSArray *)newCoordinates;


//removing coordinates
- (void)removeCoordinate:(ARCoordinate *)coordinate;
- (void)removeCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated;

- (void)removeCoordinates:(NSArray *)coordinates;

- (id)initWithLocationManager:(CLLocationManager *)manager;

- (void)startListening;
- (void)stopListening;
- (void)updateLocations:(NSTimer *)timer;

- (CGPoint)pointInView:(UIView *)realityView forCoordinate:(ARCoordinate *)coordinate;

- (BOOL)viewportContainsCoordinate:(ARCoordinate *)coordinate;
- (void)dismissCamera;
- (void)updateCoordinates:(NSArray*)newCoordinates;

@property (nonatomic, retain) UIImagePickerController *cameraController;

@property (nonatomic, assign) id<ARViewDelegate> delegate;
@property (nonatomic, assign) id<ARViewDataSource> datasource;
@property (nonatomic, assign) id<CLLocationManagerDelegate> locationDelegate;
@property (nonatomic, assign) id<UIAccelerometerDelegate> accelerometerDelegate;

@property (retain) ARCoordinate *centerCoordinate;

@property (nonatomic, retain) UIAccelerometer *accelerometerManager;
@property (nonatomic, retain) CLLocationManager *locationManager;


- (UIImage*)getImageFromName:(NSString*)imageName;
@end
