

#import <UIKit/UIKit.h>
#import "GPSLocationsParser.h"
#import "StoreAnnotation.h"
#import <MapKit/MKMapView.h>
#import "StoreLocation.h"
#import "WebServicesManager.h"
#import "WEPopoverController.h"
#import "UserAnnotation.h"
#import "StoreLocatorDetailViewController.h"
#import "StoreLocatorConfigurationViewController.h"
#import "WBaseViewController.h"
#import "ARGeoViewController.h"
#import "MPRouteDestinationsViewcontroller.h"

#define MAX_LOCATIONS 50
#define MAX_LOCATIONS_METERS 25
#define DEFAULT_LOCATIONS 25

MKMapPoint *incrementMemory(MKMapPoint *points, int *count, int increment);

@class GoogleConnection;
@class WEPopoverContainerView;
@class WEPopoverController;
@class WEPopoverContainerViewProperties;
@protocol WebServicesObserver;
@protocol StoreLocatorDetailDelegate;
@protocol WEPopoverControllerDelegate;
@interface MPRouteViewController : WBaseViewController <GPSLocationsParserDelegate, /*UITableViewDataSource, UITableViewDelegate,*/ WebServicesObserver, StoreLocatorDetailDelegate, StoreLocationConfigurationDelegate, WEPopoverControllerDelegate, ARViewDelegate, ARViewDataSource, ARLocationViewDelegate, CLLocationManagerDelegate, MPRouteDestinationsDelegate> {
    GPSLocationsParser *gpsParser;
    NSArray *storesLocationsArray;
    NSMutableSet *annotationsPool;
    NSMutableSet *walmartAnnotations;
    NSMutableSet *samsAnnotations;
    NSMutableSet *portonAnnotations;
    NSMutableSet *allStoresAnnotations;
    NSMutableDictionary *imagesDict;
    NSMutableArray *currentMapLocations;
    BOOL isFilterHidden;
    StoreType storeFilter;
    BOOL firstUserLocation;
    NSInteger storesMask;
    CLLocationCoordinate2D userLocation;
    MKMapRect routeRect;
    StoreAnnotation *routeAnnotation;
    BOOL isInRouteMode;
    TableType tableType;
    NSInteger currentDistanceConf;
    NSMutableArray *annotationViews;
    NSInteger currentSegmentIndex;
    StoreLocatorConfigurationViewController *configController;
    int currentMaxStores;
    NSMutableArray *routeLocationsArray;
    CLLocationManager *locationManager;
    MKMapPoint northEastPoint;
    MKMapPoint southWestPoint;
}

@property (nonatomic, retain) IBOutlet MKMapView *storeMapView;
@property (nonatomic, retain) IBOutlet UIView *filterView;
@property (nonatomic, retain) IBOutlet UILabel *addressLabel;
@property (nonatomic, retain) IBOutlet UITableView *filterTableView;
@property (nonatomic, retain) IBOutlet UIToolbar *bottomBar;
@property (nonatomic, retain) IBOutlet UIView *navigationView;

//details
@property (nonatomic, retain) IBOutlet UIView *detailView;
@property (nonatomic, retain) IBOutlet UIImageView *storeImageView;
@property (nonatomic, retain) IBOutlet UILabel *storeNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *storeAddressLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;
@property (nonatomic, retain) IBOutlet UILabel *userLocationAddressLabel;
@property (nonatomic, retain) IBOutlet UILabel *serviceHours;
@property (nonatomic, retain) StoreLocation *detailLocation;

@property (nonatomic, retain) NSArray *storesLocationsArray;
@property (nonatomic, retain) NSMutableArray *currentMapLocations;
@property (nonatomic, retain) GPSLocationsParser *gpsParser;
@property (nonatomic, retain) MKPolylineView *routeLineView;
@property (nonatomic, retain) MKPolylineView *segmentLineView;
@property (nonatomic, retain) MKPolyline *routeLine;
@property (nonatomic, retain) MKPolyline *segmentLine;
@property (nonatomic, retain) StoreAnnotation *routeAnnotation;
@property (nonatomic, retain) UserAnnotation *userAnnotation;
@property (nonatomic, retain) NSMutableArray *enabledStores;
@property (nonatomic, retain) NSMutableIndexSet *filteredStores;
@property (nonatomic, retain) WEPopoverController *popoverController;
@property (nonatomic, retain) ARGeoViewController *arGeoViewController;
@property (nonatomic, retain) NSArray *distances;
@property (nonatomic, retain) NSMutableArray *directionsArray;
@property (nonatomic, retain) NSMutableDictionary *routeDistanceAndtime;
@property (nonatomic, retain) IBOutlet UIButton *mapButton;
@property (nonatomic, retain) IBOutlet UIButton *directionsButton;
@property (nonatomic, retain) IBOutlet UIView *addressView;
@property (nonatomic, retain) NSMutableSet *annotationsPool;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *navigationButtons;
@property (nonatomic, retain) NSMutableArray *directionsAnnotationsArray;




//- (void)buildStoreLocationsSet;
- (UIImage*)getImageFromName:(NSString*)imageName;
- (BOOL) isTypeEnabled:(StoreType)type;
//- (void)setMask:(StoreType)type toValue:(BOOL)value;
- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber;
- (CLLocationDistance)distanceFromLocation:(CLLocationCoordinate2D)d1 toLocation:(CLLocationCoordinate2D)d2;

- (NSArray*) getLocationsNearLocation:(CLLocationCoordinate2D)location andSpan:(MKCoordinateSpan)span inMeters:(BOOL)isDistanceInMeters;
- (double)getDistanceFromLocation:(CLLocationCoordinate2D)origin toLocation:(CLLocationCoordinate2D)destination;
- (StoreAnnotation*) getAnnotationFromMapWithLocation:(StoreLocation*)location;
- (void)updateLocationsInMapWithLocation:(CLLocationCoordinate2D)locationCoordinate andSpan:(MKCoordinateSpan)span;
- (void)toggleStoreFilter:(StoreType)type;
- (void) zoomInOnRoute;
-(void) zoomInOnRouteSegment:(MKMapPoint*)points count:(NSInteger)count;
- (void)setNavigationButtonsHidden:(BOOL)hidden;

-(MKPolyline *) loadRouteWithPoints:(NSArray*)routePoints;
#if USE_GOOGLE
-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded;
#else
-(NSMutableArray *)decodePolyLine: (NSArray *)points;
#endif
- (IBAction)navgationbButtonpressed:(id)sender;
- (IBAction)storeLocatorButtonPressed:(id)sender;
- (void)showDetailOfLocation:(StoreLocation*)location;
- (UIImage*)getImageFromName:(NSString*)imageName;
@end
