

#import "MPRouteViewController.h"
#import <MapKit/MKUserLocation.h>
#import <QuartzCore/CAAnimation.h>
#import "WEPopoverController.h"
#import "MKMapView+ZoomLevel.h"
#import "UIViewController+GetButton.h"
#import "UIColor+RGB.h"
#import "NSString+IsNumber.h"
#import "UIView+getFirstResponder.h"
#import "UIViewController+GetButton.h"
#import "CustomToolbar.h"
#import "SLRoute.h"
#import "DirectionAnnotation.h"
#import "Definitions.h"
#import "ARGeoCoordinate.h"
#import "DirectionAnnotationView.h"
#import "JSONKit.h"
#import <AVFoundation/AVFoundation.h>


#define MY_LAT 19.454129
#define MY_LON -99.15925

#define ROUTE_COLOR 0x0d4820
#define ROUTE_SEGMENT_COLOR 0x609c71


#define DIST_1 1000
#define DIST_2 3000
#define DIST_3 5000
#define DIST_4 10000

//#define MAX_STORES 10
//#define MAX_STORES 25
//#define MAX_STORES 50

#define GET_RADIUS(x, y) sqrt(x*x+y*y)

MKMapPoint *incrementMemory(MKMapPoint *points, int *count, int increment) {
    *count = *count + increment;
    MKMapPoint *tempPointArr = malloc(sizeof(CLLocationCoordinate2D) * (*count));
    memcpy(tempPointArr, points, sizeof(CLLocationCoordinate2D) * (*count));
    return tempPointArr;
}

@interface MPRouteViewController ()
@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;
@end

@implementation MPRouteViewController
@synthesize storeMapView;
@synthesize filterView;
@synthesize filterTableView;
@synthesize storesLocationsArray;
@synthesize gpsParser;
@synthesize addressLabel;
@synthesize routeLineView;
@synthesize segmentLineView;
@synthesize routeLine;
@synthesize segmentLine;
@synthesize routeAnnotation;
@synthesize userAnnotation;
@synthesize currentMapLocations;
@synthesize enabledStores;
@synthesize filteredStores;
@synthesize popoverController;
@synthesize distances;
@synthesize bottomBar;
@synthesize directionsArray;
@synthesize mapButton;
@synthesize directionsButton;
@synthesize annotationsPool;
@synthesize navigationButtons;
@synthesize directionsAnnotationsArray;
@synthesize navigationView;
@synthesize arGeoViewController;
@synthesize addressView;

// details
@synthesize detailView;
@synthesize storeImageView;
@synthesize storeNameLabel;
@synthesize storeAddressLabel;
@synthesize distanceLabel;
@synthesize detailLocation;
@synthesize userLocationAddressLabel;
@synthesize serviceHours;
@synthesize routeDistanceAndtime;

typedef enum {
    BusinessTypeWalmart = 0,
    BusinessTypeSamsClub,
    BusinessTypeSuburbia,
    BusinessTypePorton,
    BusinessTypeAurrera,
    BusinessTypeVips,
    BusinessTypeSuperama,
    BusinessTypeCount,
}BusinessType ;


/*static NSInteger StoreMaskAll        = 0;
 static NSInteger StoreMaskWalmart    = 1<<0;
 static NSInteger StoreMaskSamsClub   = 1<<1;
 static NSInteger StoreMaskSuburbia   = 1<<2;
 static NSInteger StoreMaskPorton     = 1<<3;
 static NSInteger StoreMaskAurrera    = 1<<4;
 static NSInteger StoreMaskVips       = 1<<5;
 static NSInteger StoreMaskSuperama   = 1<<6;
 static NSInteger StoreMaskAllEnabled = 0x7f;*/

- (void)dealloc
{
    self.storeMapView = nil;
    self.storesLocationsArray = nil;
    [self.gpsParser cancel];
    self.gpsParser = nil;
    [[WebServicesManager defaultManager] removeObserver:self];
    [self.directionsAnnotationsArray removeAllObjects];
    [self.storeMapView removeAnnotations:[self.storeMapView annotations]];
    self.directionsAnnotationsArray = nil;
    self.storeMapView = nil;
    self.enabledStores = nil;
    self.currentMapLocations = nil;
    self.routeAnnotation = nil;
    self.distances = nil;
    self.directionsArray = nil;
    self.directionsButton = nil;
    self.mapButton = nil;
    self.filteredStores = nil;
    self.annotationsPool = nil;
    self.navigationButtons = nil;
    self.addressView = nil;
    self.routeDistanceAndtime = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    isFilterHidden = YES;
    firstUserLocation = NO;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    isInRouteMode = NO;
    self.enabledStores = [NSMutableArray array];
    [self.enabledStores addObject:[NSNumber numberWithInt:StoreTypeWalmart]];
    [self.enabledStores addObject:[NSNumber numberWithInt:StoreTypeSuperama]];
    [self.enabledStores addObject:[NSNumber numberWithInt:StoreTypeSamsClub]];

	self.filteredStores = [NSMutableIndexSet indexSet];
    [self toggleStoreFilter:StoreTypeSuperama];    
    self.distances = [NSArray arrayWithObjects:[NSNumber numberWithInt:DIST_1],[NSNumber numberWithInt:DIST_2], [NSNumber numberWithInt:DIST_3], [NSNumber numberWithInt:DIST_4], nil];
    self.annotationsPool = [NSMutableSet set];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"currentDistanceConf"]) {
        currentDistanceConf = [[[NSUserDefaults standardUserDefaults] objectForKey:@"currentDistanceConf"] intValue];
    } else {
        currentDistanceConf = DIST_4;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"currentMaxStores"]) {
        currentMaxStores = [[[NSUserDefaults standardUserDefaults] objectForKey:@"currentMaxStores"] intValue];
    } else {
        currentMaxStores = DEFAULT_LOCATIONS;
    }
    
    storeFilter = StoreTypeNoType;
    
    currentSegmentIndex = -1;
    
    [detailView setTransform:CGAffineTransformMakeScale(0.01, 0.01)];
    [self addObserver:self forKeyPath:@"addressView.frame" options: NSKeyValueObservingOptionNew context:NULL];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //user needs to press for 2 seconds
    [self.storeMapView addGestureRecognizer:lpgr];
    
    self.directionsAnnotationsArray = [NSMutableArray array];
    self.directionsArray = [NSMutableArray array];
    
    [self initSpeechSystem];
}

- (void)frameDidChangeInView:(UIView *)aView from:(CGRect)from to:(CGRect)to {
//    if (aView == self.addressView) {
//        if (!CGRectEqualToRect(from, to) && !CGRectEqualToRect(to, CGRectMake(0, 1, 320, 42))) {
//            self.addressView.frame = CGRectMake(0, 1, 320, 42);
//            self.navigationItem.leftBarButtonItem.customView.frame = CGRectMake(0, 0, 42, 30);
//        }
//    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSRange rangeOfFrameString = [keyPath rangeOfString:@"frame"];
    
    if(rangeOfFrameString.location != NSNotFound) {
        
        UIView *targetView = nil;
        
        if(rangeOfFrameString.location > 0) { // say e.g. @"property.contentView.frame" then keypath for the target view is @"property.contentView"
            NSString *keyPathToTargetView = [keyPath substringToIndex:rangeOfFrameString.location - 1];
            targetView = [object valueForKeyPath:keyPathToTargetView];
        }
        else {
            targetView = object;
        }
        
        BOOL targetIsUIView = [targetView isKindOfClass:[UIView class]];
        
        if(targetIsUIView) {
            
            if([self isViewLoaded]) {
                
                CGRect oldFrame = CGRectNull;
                CGRect newFrame = CGRectNull;
                if([change objectForKey:NSKeyValueChangeOldKey] != [NSNull null]) {
                    oldFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
                }
                if([change objectForKey:NSKeyValueChangeNewKey] != [NSNull null]) {
                    newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
                }
                
                BOOL prior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
                
                if(prior) {
                    // sent before a change will occur
                }
                else {
                    
                    if(!CGRectEqualToRect(oldFrame, newFrame)) { // we got change in frame
                        [self frameDidChangeInView:targetView from:oldFrame to:newFrame];
                    }
                }  
            }
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.storeMapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.storeMapView convertPoint:touchPoint toCoordinateFromView:self.storeMapView];
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    [self.storeMapView addAnnotation:annot];
    
    if (!routeLocationsArray) {
        routeLocationsArray = [[NSMutableArray alloc] init];
    }
    [routeLocationsArray addObject:annot];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.arGeoViewController) {
        [self.arGeoViewController dismissCamera];
        //        self.navigationController.wantsFullScreenLayout = NO;
        [self.arGeoViewController.view removeFromSuperview];
        self.arGeoViewController = nil;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect navigationToolbarFrame = self.navigationController.navigationBar.frame;

    navigationToolbarFrame.origin.y = 0;
//    [UIView animateWithDuration:duration animations:^{
//        self.navigationItem.rightBarButtonItem.customView.frame = navigationToolbarFrame;     
//    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.storesLocationsArray) return;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
//	[self showLoadingView];
    self.navigationItem.hidesBackButton = YES;
    UIButton *button = [self getButtonFromType:SuperiorBarButtonHomeSquare];
    [button addTarget:self action:@selector(popNavigationViewControllerAnimated) forControlEvents:UIControlEventTouchUpInside];

//    [self.bottomBar removeFromSuperview];
    self.navigationItem.titleView = self.bottomBar;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

}

#pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    NSString *identifier = nil;
    MKAnnotationView *annotationView = nil;
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
        MKUserLocation *anAnnotation = (MKUserLocation *)annotation;
        [anAnnotation setTitle:@"Mi ubicación"];
        if ([self.addressLabel.text length] > 0) 
        {   
            [anAnnotation setSubtitle:self.addressLabel.text];
        }
		identifier =  [NSString stringWithFormat:@"UserLocation"];
		
		annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		
		if (!annotationView) {
			annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            
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
		
        
		return annotationView;
	} else if ([annotation isKindOfClass:[StoreAnnotation class]]) {
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
#if DEBUG_MODE
            NSLog(@"%@", NSStringFromCGRect(frame));
#endif
            [annotationView setFrame:frame];
		}
        //annotationView.alpha = 0;
        [annotationView setTransform:CGAffineTransformMakeScale(0.01, 0.01)];
        
		[annotationView setLeftCalloutAccessoryView:(UIView *)storeAnnotation.leftCalloutView];
        
		return annotationView;
	} else if ([annotation isKindOfClass:[DirectionAnnotation class]]){ 
        identifier = [NSString stringWithFormat:@"DirectionAnnotationView"];
        annotationView = (DirectionAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!annotationView) {
			annotationView = [[DirectionAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            /*if ([[[dirAnnotation dictionary] objectForKey:@"selected"] boolValue])
             {
             [annotationView setPinColor:MKPinAnnotationColorPurple];
             } else {
             [annotationView setPinColor:MKPinAnnotationColorRed];
             }*/
            
            //annotationView.animatesDrop = YES;
//            UIImage *image = [UIImage imageNamed:@"circulo_paso_ruta"];
            
//			[annotationView setImage:image];
			[annotationView setCanShowCallout:YES];
        }
        [annotationView setTag:66];
        [annotationView setAnnotation:annotation];
        [annotationView setNeedsDisplay];
        return annotationView;
        
    } else {
        
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
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views { 
    for (MKAnnotationView *view in views) {
        CGFloat delay = (float)(arc4random()%150)/1000.00;
        if ([view.annotation isKindOfClass:[StoreAnnotation class]])
            [view performSelector:@selector(animateBlossom) withObject:nil afterDelay:delay];
    }
}


- (MKOverlayView *)mapView:(MKMapView *)map viewForOverlay:(id <MKOverlay>)overlay
{
	MKOverlayView* overlayView = nil;
	
	if(overlay == self.routeLine)
	{
		//if we have not yet created an overlay view for this overlay, create it now. 
        [self.routeLineView removeFromSuperview];
		//if(nil == self.routeLineView)
		{
			self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
			self.routeLineView.fillColor = [UIColor colorWithRGBValue:ROUTE_COLOR];
			self.routeLineView.strokeColor = [UIColor colorWithRGBValue:ROUTE_COLOR];
			self.routeLineView.lineWidth = 10;
            self.routeLineView.alpha = 1.0;
            
		}
		
		overlayView = self.routeLineView;
	} else if ([overlay isKindOfClass:[MKPolyline class]]) {
        self.segmentLineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        self.segmentLineView.fillColor = [UIColor colorWithRGBValue:ROUTE_SEGMENT_COLOR];
        self.segmentLineView.strokeColor = [UIColor colorWithRGBValue:ROUTE_SEGMENT_COLOR];
        self.segmentLineView.lineWidth = 10;
        self.segmentLineView.alpha = 1.0;
        overlayView = self.segmentLineView;
    }
	
	return overlayView;
	
}



- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)_userLocation{
	BOOL update = FALSE;
	if (userLocation.longitude != mapView.userLocation.location.coordinate.longitude || userLocation.latitude != mapView.userLocation.location.coordinate.latitude)
		update = TRUE;
#if TARGET_IPHONE_SIMULATOR
    userLocation = CLLocationCoordinate2DMake(MY_LAT, MY_LON);
#else
    userLocation = mapView.userLocation.location.coordinate;
#endif
	if (update) {
		[self.currentMapLocations removeAllObjects];
		[self.currentMapLocations addObjectsFromArray:[self getLocationsNearLocation:userLocation andSpan:mapView.region.span inMeters:YES]];
	}
    if (!firstUserLocation) 
    {
		//[self showLoadingView];
        [mapView setCenterCoordinate:userLocation zoomLevel:12 animated:YES];
        firstUserLocation = YES;
        [WebServicesManager  connectWithType:WSConnectionTypeGoogleInverseGeocoding singleParam:nil jsonParam:nil originLocation:userLocation destLocation:CLLocationCoordinate2DMake(0,0) withObserver:self];
    }
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    CLLocationCoordinate2D currentLocationCoordinate2D = mapView.centerCoordinate;
    MKCoordinateSpan mapViewCurrentSpan = MKCoordinateSpanMake(mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
    
    if (currentLocationCoordinate2D.longitude == -180) return;
//	[self updateLocationsInMapWithLocation:currentLocationCoordinate2D andSpan:mapViewCurrentSpan];
}

#pragma mark -
#pragma mark Actions

- (IBAction) storesButtonPressed:(id)sender {
    UIButton *button = sender;
    TableType newTableType = [button tag];
    
    if (self.popoverController){
        StoreLocatorConfigurationViewController *controller = (StoreLocatorConfigurationViewController*) self.popoverController.contentViewController;
        if (controller.type == newTableType)
        {
            [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController = nil;
//            return;
        }
    }
    switch (newTableType) {
        case TableTypeNearMe:
        {
            StoreLocatorConfigurationViewController *contentViewController = [[StoreLocatorConfigurationViewController alloc] initWithType:newTableType dataSource:self.currentMapLocations selectedItems:nil delegate:self];
            contentViewController.delegate = self;
            
            self.popoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController] ;
            
            if ([self.popoverController respondsToSelector:@selector(setContainerViewProperties:)]) {
                [self.popoverController setContainerViewProperties:[self getContainerViewProperties]];
            }
            
            self.popoverController.delegate = self;
            
            
            //self.popoverController.passthroughViews = [NSArray arrayWithObjects:self.view, self.navigationItem.rightBarButtonItem.customView, self.navigationItem, nil];
            
//            CustomToolbar *toolBar = (CustomToolbar*)[self.navigationItem.rightBarButtonItem customView];
//            UIBarButtonItem *listsButton = [[toolBar items] objectAtIndex:6];
            
//            [self.popoverController presentPopoverFromBarButtonItem:listsButton
//                                           permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
//                                                           animated:YES];
            [self.view addSubview:contentViewController.view];
            
//            [contentViewController release];
        }
            break;
        case TableTypeStoresCatalog:
        {
            StoreLocatorConfigurationViewController *contentViewController = [[StoreLocatorConfigurationViewController alloc] initWithType:newTableType dataSource:self.enabledStores selectedItems:self.filteredStores delegate:self];
            contentViewController.delegate = self;
            
            self.popoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
            
            if ([self.popoverController respondsToSelector:@selector(setContainerViewProperties:)]) {
                [self.popoverController setContainerViewProperties:[self getContainerViewProperties]];
            }
            
            self.popoverController.delegate = self;
            
            
            //self.popoverController.passthroughViews = [NSArray arrayWithObjects:self.view, self.navigationItem.rightBarButtonItem.customView, self.navigationItem, nil];
            
            CustomToolbar *toolBar = (CustomToolbar*)[self.navigationItem.rightBarButtonItem customView];
            UIBarButtonItem *listsButton = [[toolBar items] objectAtIndex:5];
            
            [self.popoverController presentPopoverFromBarButtonItem:listsButton
                                           permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
                                                           animated:YES];
            
        }
            break;
        case TableTypeConfiguration:
        {
            if (routeLocationsArray.count < 2)
                return;
            [self getRouteWithType:RouteTypeCar];
            return;
            if (configController && configController.type == TableTypeConfiguration) {
                return;
            }
            
            NSIndexSet *selected = [NSIndexSet indexSetWithIndex:currentDistanceConf];
            StoreLocatorConfigurationViewController *contentViewController = [[StoreLocatorConfigurationViewController alloc] initWithType:newTableType dataSource:self.currentMapLocations selectedItems:selected delegate:self];
            contentViewController.delegate = self;
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setObject:[NSNumber numberWithInt:currentDistanceConf/1000] forKey:@"currentDistance"];
            [info setObject:[NSNumber numberWithInt:currentMaxStores] forKey:@"currentMaxStores"];
            contentViewController.extraInfo = info;
//            self.popoverController = [[[WEPopoverController alloc] initWithContentViewController:contentViewController] autorelease];
//            
//            if ([self.popoverController respondsToSelector:@selector(setContainerViewProperties:)]) {
//                [self.popoverController setContainerViewProperties:[self getContainerViewProperties]];
//            }
            
//            self.popoverController.delegate = self;
//            self.popoverController.passthroughViews = [NSArray arrayWithObjects:self.view, self.navigationItem.rightBarButtonItem.customView, self.navigationItem, nil];
            
//            UIBarButtonItem *item = nil;
//            for (item in self.bottomBar.items) {
//                if (item.customView == button) {
//                    break;
//                }
//            }
            
//            [self.popoverController presentPopoverFromBarButtonItem:item
//                                           permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
//                                                           animated:YES];
            
            if (configController)
                [configController dismiss];
            configController = contentViewController;
            [self.view performSelector:@selector(addSubview:) withObject:contentViewController.view afterDelay:0.1];
            
            
//            [contentViewController release];
        }
            break;
        case TableTypeDirections:
        {
            if (!self.directionsArray) return;
            if (configController && configController.type == TableTypeDirections) {
                return;
            }
            StoreLocatorConfigurationViewController *contentViewController = [[StoreLocatorConfigurationViewController alloc] initWithType:newTableType dataSource:self.directionsArray selectedItems:nil delegate:self];
            contentViewController.delegate = self;
            contentViewController.extraInfo = self.routeDistanceAndtime;
//            self.popoverController = [[[WEPopoverController alloc] initWithContentViewController:contentViewController] autorelease];
//            
//            if ([self.popoverController respondsToSelector:@selector(setContainerViewProperties:)]) {
//                [self.popoverController setContainerViewProperties:[self getContainerViewProperties]];
//            }
//            
//            self.popoverController.delegate = self;
            
            
//            self.popoverController.passthroughViews = [NSArray arrayWithObjects:self.view, self.navigationItem.rightBarButtonItem.customView, self.navigationItem, nil];
            
            
//            CustomToolbar *toolBar = (CustomToolbar*)[self.navigationItem.rightBarButtonItem customView];
//            UIBarButtonItem *listsButton = nil;
//            for (UIBarButtonItem *item in [self.bottomBar items]) {
//                if (item.customView && item.customView == button) {
//                    listsButton = item;
//                    break;
//                }
//            }
//            [self.popoverController presentPopoverFromBarButtonItem:listsButton
//                                           permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
//                                                           animated:YES];
            if (configController) {
                [configController dismiss];
                [detailView dismissBlossom];
            }
            configController = contentViewController;
            [self.view performSelector:@selector(addSubview:) withObject:contentViewController.view afterDelay:0.1];
            
//            [contentViewController release];
        }
            break;
    }
}

- (IBAction) disclosureButtonTouchUpInside:(id)sender {
	UIButton *disclosureButton = (UIButton *)sender;
	UIView *calloutView = [disclosureButton superview];
    
	MKAnnotationView *annotationView = (MKAnnotationView *)[calloutView superview];
	StoreAnnotation *annotation = (StoreAnnotation *)[annotationView annotation];
	StoreLocation *location = annotation.location;
    //self.routeAnnotation = annotation;
    //location.distanceInMeters = [self distanceFromLocation:userLocation toLocation:location.coordinate];
//    StoreLocatorDetailViewController *detailviewController = [[[StoreLocatorDetailViewController alloc] initWithLocation:location delegate:self] autorelease];
//    [self.navigationController pushViewController:detailviewController animated:YES];
    
    [self showDetailOfLocation:location];
}

- (IBAction)storeLocatorButtonPressed:(id)sender {
    UIButton *button = sender;
    switch ([button tag]) {
        case 1:
        {
            MKCoordinateRegion region = MKCoordinateRegionMake(userLocation, self.storeMapView.region.span);
            [self.storeMapView setRegion:region animated:YES];
            //[self showLoadingView];
            [WebServicesManager connectWithType:WSConnectionTypeGoogleInverseGeocoding singleParam:nil jsonParam:nil originLocation:userLocation destLocation:CLLocationCoordinate2DMake(0,0) withObserver:self];            
#if USE_TRACKING_MODE
            if (self.storeMapView.userTrackingMode == MKUserTrackingModeNone) {
                [self.storeMapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
            } else {
                [self.storeMapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
            }
#endif
        }
            break;
        case 2:
            if ([self.storeMapView mapType] == MKMapTypeStandard) {
                [self.storeMapView setMapType:MKMapTypeHybrid];
                [button setImage:[UIImage imageNamed:@"btnMapa_mapa"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"btnMapa_mapa_press"] forState:UIControlStateHighlighted];
            } else {
                [self.storeMapView setMapType:MKMapTypeStandard];
                [button setImage:[UIImage imageNamed:@"btnSatelite_mapa"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"btnSatelite_mapa_press"] forState:UIControlStateHighlighted];
            }
            
            break;
        default:
            break;
    }
}

- (IBAction)mapButtonPressed:(UIButton*)button {
    isInRouteMode = !isInRouteMode;
    
//    if (isInRouteMode) {
//        [self.mapButton setImage:[UIImage imageNamed:@"btnMapa_barraSuperior"] forState:UIControlStateNormal];
//        [self.mapButton setImage:[UIImage imageNamed:@"btnMapa_barraSuperior_press"] forState:UIControlStateHighlighted];
//        [self.storeMapView addOverlay: self.routeLine];
//        if (self.segmentLine){
//            [self.storeMapView addOverlay: self.segmentLine];
//        }
////        [self.storeMapView addAnnotations:self.directionsAnnotationsArray];
//        [self.directionsButton setHidden:NO];
//        [self setNavigationButtonsHidden:NO];
//    } else {
        [self.mapButton setImage:[UIImage imageNamed:@"btnRuta_barraSuperior"] forState:UIControlStateNormal];
        [self.mapButton setImage:[UIImage imageNamed:@"btnRuta_barraSuperior_press"] forState:UIControlStateHighlighted];
        [self.storeMapView removeOverlay:self.routeLine];
        if (self.segmentLine) {
            [self.storeMapView removeOverlay:self.segmentLine];
        }
        [self.storeMapView removeAnnotations:self.directionsAnnotationsArray];
        [self.directionsAnnotationsArray removeAllObjects];
        [self.routeLineView removeFromSuperview];
//        [self.directionsButton setHidden:YES];
        [self.mapButton setHidden:YES];
        self.routeLineView = nil;
        [self.storeMapView removeAnnotations:routeLocationsArray];
        [routeLocationsArray removeAllObjects];
        if (configController && configController.type == TableTypeDirections) {
            [configController dismiss];
        }
        [self setNavigationButtonsHidden:YES];
        
//    }
//    [self updateLocationsInMapWithLocation:userLocation andSpan:self.storeMapView.region.span];
    [self.storeMapView setNeedsDisplay];
}

- (IBAction)navgationbButtonpressed:(id)sender {
    UIButton *button = sender;
    
    NSInteger lastIndex = currentSegmentIndex;
    if ([button tag] == 0) { //previous
        currentSegmentIndex--;
        if (currentSegmentIndex < -1) {
            currentSegmentIndex = -1;
            return;
        } else if (currentSegmentIndex < 0) {
            currentSegmentIndex = 0;
            return;
        }
    } else { //next
        currentSegmentIndex++;
        if (currentSegmentIndex > [directionsArray count] - 1) {
            currentSegmentIndex = [directionsArray count] - 1;
            return;
        }
    }
    if (configController) {
        [configController dismiss];
    }
    if (lastIndex >= 0)
        [[self.directionsArray objectAtIndex:lastIndex] removeObjectForKey:@"selected"];
    [[self.directionsArray objectAtIndex:currentSegmentIndex] setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
    
    NSDictionary *dict = [self.directionsArray objectAtIndex:currentSegmentIndex];
    SLRoute *route = nil;
    if (currentSegmentIndex != lastIndex && self.segmentLine) {
        [self.storeMapView removeOverlay:self.segmentLine];
        [self.segmentLineView removeFromSuperview];
        self.segmentLineView = nil;
        self.segmentLine = nil;
    } else if (currentSegmentIndex == lastIndex) {
        return;
    }
    route = [[directionsArray objectAtIndex:currentSegmentIndex] objectForKey:@"route"];
    self.segmentLine = [MKPolyline polylineWithPoints:route.points count:route.count];
    [self.storeMapView addOverlay:self.segmentLine];
    [self zoomInOnRouteSegment:route.points count:route.count];
    DirectionAnnotation *annotation = 0;
    for (annotation in self.directionsAnnotationsArray) {
        if ([annotation.dictionary isEqualToDictionary:dict]) {
            break;
        }
    }
    
    NSString *stringTitle = [annotation subtitle];
    
    [self speak:stringTitle];
    [self performSelector:@selector(selectAnnotation:) withObject:annotation afterDelay:0.25];
    
}

- (void)selectAnnotation:(id<MKAnnotation>)annotation {
    [self.storeMapView selectAnnotation:annotation animated:YES];
}

- (IBAction)detailButtonPressed:(id)sender {
    UIButton *button = sender;
    switch ([button tag]) {
        case 0:
        case 1:
            [self getRouteWithType:[button tag]];
            break;
        case 2:
            if (configController) {
                if (configController.type == TableTypeDirections) {
                    [configController dismiss];
                } else {
                    [configController show];
                }
            }
            
            [detailView dismissBlossom];
            break;
    }
}


- (IBAction)augmentedRealityButtonPressed:(id)sender {
    UIButton *button = sender;
    if (!self.arGeoViewController) {
        //    arViewController.view.frame = self.storeMapView.frame;
//        [self.navigationController setWantsFullScreenLayout: YES];
        self.arGeoViewController = [[ARGeoViewController alloc] init];
        self.arGeoViewController.datasource = self;
        self.arGeoViewController.delegate = self;
//        [self presentViewController:self.arGeoViewController animated:YES completion:^{
//        }];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self.view addSubview:self.arGeoViewController.view];
        [self.view bringSubviewToFront: self.bottomBar];
        
        
        [self.mapButton setHidden:YES];
//        [self.directionsButton setHidden:YES];
        [(UIBarButtonItem*)[self.bottomBar.items objectAtIndex:6] customView].hidden = YES;
        [(UIBarButtonItem*)[self.bottomBar.items objectAtIndex:7] customView].hidden = YES;
        [button setImage:[UIImage imageNamed:@"btnMapa_barraInferior"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"btnMapa_barraInferior_press"] forState:UIControlStateHighlighted];
    } else {
        [self.arGeoViewController dismissCamera];
        [self.arGeoViewController.view removeFromSuperview];
        [(UIBarButtonItem*)[self.bottomBar.items objectAtIndex:6] customView].hidden = NO;
        [(UIBarButtonItem*)[self.bottomBar.items objectAtIndex:7] customView].hidden = NO;
        if ([self.directionsArray count] != 0) {
            [self.mapButton setHidden:NO];
            if (isInRouteMode)
                [self.directionsButton setHidden:NO];
        }
        
        NSLog(@"%@", NSStringFromCGRect(self.addressView.frame));
        self.arGeoViewController = nil;
        [button setImage:[UIImage imageNamed:@"btnBrujula_barraInferior"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"btnBrujula_barraInferior_press"] forState:UIControlStateHighlighted];
    }
}


#pragma mark - WebServicesObserver

- (void)webServicesConnectionDidFinish:(NSNotification*)notification { // userInfo will contain data
    NSDictionary *resultDictionary = [[notification userInfo] objectForKey:@"resultDictionary"];
    WSConnectionType type = [[[notification userInfo] objectForKey:@"type"] intValue];
    id jsonObject = resultDictionary;
    NSDictionary *dict = nil;
    switch (type) {
        case WSConnectionTypeGoogleTraceroute:
        case WSConnectionTypeGoogleTracerouteOnFoot:
        {
            NSDictionary *storeDictionary = jsonObject;
            
            if ([storeDictionary count] == 0) {
                [self showAlertViewWithTitle:ALERTVIEW_TITLE message:@"No se pudo obtener una ruta." buttonTitle:@"Aceptar"];
                [self dismissLoadingView];
                return;
            }
            isInRouteMode = YES;
            NSLog(@"%@",[storeDictionary JSONString]);
            if (self.arGeoViewController) {
                [self dismissARView];
            }
            [self.mapButton setHidden:NO];
            [self.directionsButton setHidden:NO];
//            [self updateLocationsInMapWithLocation:userLocation andSpan:self.storeMapView.region.span];
            NSArray *routesArray =[storeDictionary objectForKey:@"results"];
            
            if (routesArray) {
                NSArray *routePoints = nil;
                [self resetMapAnnotations];
                
                for(NSDictionary *route in routesArray) {
                    NSArray *legsArray = [route objectForKey:@"grafo"];
                    
                    
                    //[directionsArray addObject:[route objectForKey:@"html_instructions"]];
                    
//                    for(NSArray *leg in legsArray) {
//                        routePoints=leg[12];
                        self.routeDistanceAndtime = [NSMutableDictionary dictionary];
//                        [routeDistanceAndtime setObject:[[leg objectForKey:@"distance"] objectForKey:@"text"] forKey:@"distance"];
//                        [routeDistanceAndtime setObject:[[leg objectForKey:@"duration"] objectForKey:@"text"] forKey:@"duration"];
                        self.routeLine = [self loadRouteWithPoints:legsArray];
                        currentSegmentIndex = -1;
                        if (self.routeLine != nil) {
                            [self.storeMapView addOverlay:self.routeLine];
                        }

                        NSInteger index = 0;
                        for (NSDictionary *point in self.directionsArray) {
                            DirectionAnnotation *annotation = [[DirectionAnnotation alloc] initWithDictionary:point];
                            [annotation setStepNumber:index + 1];
                            [self.directionsAnnotationsArray addObject:annotation];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.storeMapView addAnnotation:annotation];
                            });
                            index++;
                        }
//                        [self.storeMapView addAnnotations:self.directionsAnnotationsArray];
                    
                        // zoom in on the route.
                        [self zoomInOnRoute];
                        [storeMapView deselectAnnotation:routeAnnotation animated:YES];
                        
//                    }
                    
                }
                [self setNavigationButtonsHidden:NO];
            }
            [detailView dismissBlossom];
            [configController dismiss];
            [self dismissLoadingView];
        }
            break;
        case WSConnectionTypeGoogleInverseGeocoding:
            dict = jsonObject;
            if([[dict objectForKey:@"results"] count] > 0) {
                NSString *userLocationAddress = [[[dict objectForKey:@"results"] objectAtIndex:0] objectForKey:@"formatted_address"];
                self.addressLabel.text = userLocationAddress;
            }
            if (!self.storesLocationsArray) {
                self.gpsParser = [GPSLocationsParser parser];
                self.gpsParser.delegate = self;
                [self.gpsParser parseXMLFileAtURL:@"tiendas"];
                [[WebServicesManager defaultManager] removeObserver:self];
                return;
            }
            [self dismissLoadingView];
            break;
        default:
            break;
    }
    [[WebServicesManager defaultManager] removeObserver:self];
}

- (void)webServicesConnectionDidFail:(NSNotification*)notification { // userInfo will contain error
    
    WSConnectionType type = [[[notification userInfo] objectForKey:@"type"] intValue];
    [self dismissLoadingView];
    switch(type) {
        case WSConnectionTypeGoogleInverseGeocoding:
            break;
        case WSConnectionTypeGoogleTraceroute:
        case WSConnectionTypeGoogleTracerouteOnFoot:
            [self showAlertViewWithTitle:ALERTVIEW_TITLE message:@"Por favor asegúrese de estar conectado a internet\ne intente de nuevo." buttonTitle:@"Aceptar"];
            break;
        default:
            break;
    }
    [[WebServicesManager defaultManager] removeObserver:self];
}

#pragma mark - Custom

- (BOOL) isTypeEnabled:(StoreType)type{
	return [self.filteredStores containsIndex:type];
	
    /*BOOL response = NO;
     switch(type) {
     case StoreTypeWalmart:
     response = storesMask & StoreMaskWalmart;
     break;
     case StoreTypeSamsClub:
     response = storesMask & StoreMaskSamsClub;
     break;
     case StoreTypeSuburbia:
     response = storesMask & StoreMaskSuburbia;
     break;
     case StoreTypeElPorton:
     response = storesMask & StoreMaskPorton;
     break;
     case StoreTypeAurrera:
     response = storesMask & StoreMaskAurrera;
     break;
     case StoreTypeVips:
     response = storesMask & StoreMaskVips;
     break;
     case StoreTypeSuperama:
     response = storesMask & StoreMaskSuperama;
     break;
     default:
     break;
     }
     return response;*/
}

/*- (void)setMask:(StoreType)type toValue:(BOOL)value {
 NSInteger values = StoreMaskAllEnabled;
 NSInteger valueToSet = 0;
 if (value)
 {
 valueToSet = (value<<type);
 storesMask |= valueToSet;
 
 }
 else{
 valueToSet = (1<<type);
 values = StoreMaskAllEnabled - valueToSet;
 storesMask &= values;
 }
 
 NSLog(@"%x", storesMask);
 }*/

- (void)toggleStoreFilter:(StoreType)type {
	if ([self.filteredStores containsIndex:type]) {
		[self.filteredStores removeIndex:type];
	} else {
		[self.filteredStores addIndex:type];
	}
}

- (NSArray*) getLocationsNearLocation:(CLLocationCoordinate2D)location andSpan:(MKCoordinateSpan)span inMeters:(BOOL)isDistanceInMeters{
    double radius = GET_RADIUS(span.longitudeDelta, span.latitudeDelta)/2;//(span.longitudeDelta < span.latitudeDelta ? span.longitudeDelta:span.latitudeDelta) / 2;//
    if (span.longitudeDelta > 180) return nil;
    NSMutableArray *array = [NSMutableArray array];
    NSArray *retVal = nil;
    MKMapPoint origin = MKMapPointForCoordinate(userLocation);
    for (StoreLocation *l in self.storesLocationsArray) {
		if([self.filteredStores count] > 0 && ![self isTypeEnabled:[StoreAnnotation getTypeFromLocationType:l.type]])
			continue;
        MKMapPoint destination = MKMapPointForCoordinate(l.coordinate);
        CLLocationDistance lDistance = MKMetersBetweenMapPoints(origin, destination);
        if (isDistanceInMeters) {
            if (lDistance <= currentDistanceConf) 
            {           
                l.tempDistanceToPoint = lDistance;
                l.distanceInMeters = lDistance;
                [array addObject:l];
            }
        } else {
            double distance = [self getDistanceFromLocation:location toLocation:l.coordinate];
            if (distance <= radius) 
            {
                l.tempDistanceToPoint = distance;
                l.distanceInMeters = lDistance;
                [array addObject:l];
            }
        }
    }
    if (isDistanceInMeters) {
        [array sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distanceInMeters" ascending:YES]]];
    }
    else {
        [array sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tempDistanceToPoint" ascending:YES]]];
    }
    if ([array count] > (isDistanceInMeters?MAX_LOCATIONS_METERS:currentMaxStores)) {
        NSRange range;
        range.location = 0;
        range.length = isDistanceInMeters?MAX_LOCATIONS_METERS:currentMaxStores;
        retVal = [NSArray arrayWithArray:[array objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]]];
    } else {
        retVal = [NSArray arrayWithArray:array];
    }
    if(!isDistanceInMeters) {
        //NSLog(@"lat: %g, lon: %g, radius: %g", location.latitude, location.longitude, radius);
        //NSLog(@"retval: %@", retVal);
    }
    return retVal;
}

- (CLLocationDistance)distanceFromLocation:(CLLocationCoordinate2D)d1 toLocation:(CLLocationCoordinate2D)d2 {
    MKMapPoint originPoint = MKMapPointForCoordinate(d1);
    MKMapPoint destPoint = MKMapPointForCoordinate(d2);
    CLLocationDistance lDistance = MKMetersBetweenMapPoints(originPoint, destPoint);
    return lDistance;
}

- (double)getDistanceFromLocation:(CLLocationCoordinate2D)origin toLocation:(CLLocationCoordinate2D)destination {
    double latDistance = origin.latitude - destination.latitude;
    double lonDistance = origin.longitude - destination.longitude;
    return GET_RADIUS(lonDistance, latDistance);
}

-(MKPolyline *) loadRouteWithPoints:(NSArray*)routePoints
{
	
	int idxGen=0;
	
    MKPolyline *route;
	
    
    NSInteger count = [routePoints count]*100;
    NSInteger baseCount = count;
    MKMapPoint *pointArr = malloc(sizeof(CLLocationCoordinate2D) * (count));
    
    MKMapPoint *tempPointArr = NULL;
	int idx;
    int idx2;

	for(idx = 0; idx < [routePoints count]; idx++)
	{
        NSArray *pointDic = routePoints[idx];
        
        NSMutableDictionary *directionDict=[NSMutableDictionary dictionary];
        
//        NSDictionary *distanceDict=[routePoints[7]  objectForKey:@"distance"];
//        NSDictionary *durationDict=[[routePoints objectAtIndex:idx] objectForKey:@"duration"];
        
        NSArray *points = pointDic[11];
        
//        [directionDict setValue:[[routePoints objectAtIndex:idx] objectForKey:@"start_location"] forKey:@"start_location"];
        
        [directionDict setValue:pointDic[7] forKey:@"distance"];

        
//        [directionDict setValue:[durationDict objectForKey:@"text"] forKey:@"duration"];
        
//        NSString *htmlinstructions = [[routePoints objectAtIndex:idx] objectForKey:@"html_instructions"];
//        
//        NSRange range = [htmlinstructions rangeOfString:@"<div"];
//        if (range.location != NSNotFound) {
//            range.length = [htmlinstructions length] - 1 - range.location;
//            NSRange range2 = [htmlinstructions rangeOfString:@">" options:NSLiteralSearch range:range];
//            range.length = range2.location - range.location+1;
//            htmlinstructions = [htmlinstructions stringByReplacingCharactersInRange:range withString:@". "];
//        }
//        htmlinstructions = [htmlinstructions stringByReplacingOccurrencesOfString:@"</div>" withString:@""];
//        [directionDict setValue:[htmlinstructions stringByConvertingHTMLToPlainText] forKey:@"html_instructions"];
        
        NSMutableDictionary *loc = [NSMutableDictionary dictionary];
        NSArray *initialPoint = pointDic[11];
        loc[@"lat"] = initialPoint[0][1];
        loc[@"lng"] = initialPoint[0][0];
        directionDict[@"start_location"] = loc;
        directionDict[@"html_instructions"] = pointDic[2];
        
        [self.directionsArray addObject:directionDict];
        
//        pointDic=[[routePoints objectAtIndex:idx] objectForKey:@"polyline"];
        
//        NSMutableString *mutString=[pointDic objectForKey:@"points"];
        
//        NSMutableArray *decodePoints=[self decodePolyLine:mutString];
        NSMutableArray *decodePoints = [self decodePolyLine:points];
        
        int routeSegmentIndex = 0;
        MKMapPoint *routeSegmentPoints = malloc(sizeof(MKMapPoint) * ([decodePoints count]));
        for (idx2 = 0; idx2<[decodePoints count]; idx2++) {
            CLLocation *location = [decodePoints objectAtIndex:idx2];
            CLLocationCoordinate2D coord = location.coordinate;
            CLLocationCoordinate2D c = CLLocationCoordinate2DMake(coord.latitude, coord.longitude);
            MKMapPoint point = MKMapPointForCoordinate(coord);
            
            NSLog(@"%f, %f", c.latitude, c.longitude);
            
            if (idxGen == 0) {
                northEastPoint = point;
                southWestPoint = point;
            }
            else 
            {
                if (point.x > northEastPoint.x) 
                    northEastPoint.x = point.x;
                if(point.y > northEastPoint.y)
                    northEastPoint.y = point.y;
                if (point.x < southWestPoint.x) 
                    southWestPoint.x = point.x;
                if (point.y < southWestPoint.y) 
                    southWestPoint.y = point.y;
            }
            if (idxGen >= count) {
                count = count + baseCount/2;
                tempPointArr = malloc(sizeof(CLLocationCoordinate2D) * (count));
                memcpy(tempPointArr, pointArr, sizeof(CLLocationCoordinate2D) * idxGen);
                free(pointArr);
                pointArr = tempPointArr;
                tempPointArr = NULL;
                /*tempPointArr = incrementMemory(pointArr, &count, baseCount/4);
                 free(pointArr);
                 pointArr = tempPointArr;
                 tempPointArr = NULL;*/
            }
            //routeSegmentPoints[]
            routeSegmentPoints[routeSegmentIndex] = point;
            pointArr[idxGen] = point;
            idxGen++;
            routeSegmentIndex++;
            
        }
        SLRoute *route = [SLRoute routeWithPoints:routeSegmentPoints count:[decodePoints count]];
        [directionDict setObject:route forKey:@"route"];
        free(routeSegmentPoints);
        
    }
	//NSLog(@"Points: %@", self.directionsArray);
	route = [MKPolyline polylineWithPoints:pointArr count:idxGen];
    
	routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
    
	free(pointArr);
	
    return route;
}

-(void) zoomInOnRoute
{
	[self.storeMapView setVisibleMapRect:routeRect animated:YES];
}

-(void) zoomInOnRouteSegment:(MKMapPoint*)points count:(NSInteger)count
{
    MKMapPoint southWestPoint = MKMapPointMake(0, 0), northEastPoint = MKMapPointMake(0, 0), point;
    MKMapRect rect;
    int i;
    for (i = 0; i < count; i++) {
        point = points[i];
        if (i == 0) {
            northEastPoint = point;
            southWestPoint = point;
        }
        if (point.x > northEastPoint.x) 
            northEastPoint.x = point.x;
        if(point.y > northEastPoint.y)
            northEastPoint.y = point.y;
        if (point.x < southWestPoint.x) 
            southWestPoint.x = point.x;
        if (point.y < southWestPoint.y) 
            southWestPoint.y = point.y;
    }
    rect = MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(rect);
    region.span = MKCoordinateSpanMake(region.span.latitudeDelta*1.5, region.span.longitudeDelta*1.5);
    [self.storeMapView setRegion:region animated:YES];
    
}

#if USE_GOOGLE
-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded {
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *numLatitude = [NSNumber numberWithFloat:lat * 1e-5];
        NSNumber *numLongitude = [NSNumber numberWithFloat:lng * 1e-5];
        //CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        CLLocationDegrees latitude  = [numLatitude  doubleValue];
        CLLocationDegrees longitude = [numLongitude doubleValue];
        
        //NSLog(@"%f %f",[numLatitude  doubleValue],[numLongitude doubleValue]);
        
        CLLocation *towerLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [array addObject:towerLocation];
        
    }
#else 
-(NSMutableArray *)decodePolyLine: (NSArray*)points {
#endif
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSArray *location in points) {
        CLLocationDegrees latitude  = [location[1]  doubleValue];
        CLLocationDegrees longitude = [location[0] doubleValue];
        CLLocation *towerLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [array addObject:towerLocation];
    }
    
    return array;
}

- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

- (UIImage*)getImageFromName:(NSString*)imageName {
    if(!imagesDict)
        imagesDict = [[NSMutableDictionary alloc] init];
    UIImage *image = [imagesDict objectForKey:imageName];
    if (!image)
    {
        image = [UIImage imageNamed:imageName];
        [imagesDict setObject:image forKey:imageName];
    }
    
    return image;
}

- (void)setNavigationButtonsHidden:(BOOL)hidden {
    //[navigationButtons makeObjectsPerformSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:hidden]];
    [self.navigationView setVisibleWithFadeAnimation:!hidden duration:0.35];
}

- (void)showDetailOfLocation:(StoreLocation*)location {
    self.detailLocation = location;
    StoreType type = [StoreAnnotation getTypeFromLocationType:location.type];
    self.storeNameLabel.text = [NSString stringWithFormat:@"%@ %@", [StoreAnnotation getStoreNameFromType:type], location.storeName];
    self.storeAddressLabel.text = location.storeAddress;
    self.storeImageView.image = [StoreAnnotation getImageFromType:type];
    self.serviceHours.text = location.storeSchedule;
    if (location.distanceInMeters > 500) {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f km",(location.distanceInMeters/1000)];
    } else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%d m",(int)location.distanceInMeters];
    }
    [detailView animateBlossom];
}

#pragma mark - StoreLocatorDetailDelegate

- (void)StoreLocatorDetail:(StoreLocatorDetailViewController*)detailViewController GetRouteWithType:(RouteType)type {
    [self showLoadingView];
    self.routeAnnotation = [self getAnnotationFromMapWithLocation:detailViewController.location];
    if (!self.routeAnnotation)
        self.routeAnnotation = [[StoreAnnotation alloc] initWithStoreLocation:detailViewController.location];
    [WebServicesManager connectWithType:(WSConnectionTypeGoogleTraceroute + type) singleParam:nil jsonParam:nil originLocation:userLocation destLocation:self.routeAnnotation.location.coordinate withObserver:self];
}

- (void)getRouteWithType:(RouteType)type {
    [self showLoadingView];
    MKPointAnnotation *origin = routeLocationsArray[0];
    MKPointAnnotation *destination = [routeLocationsArray lastObject];

    BOOL useGet = NO;
    NSMutableArray *array = nil;
    NSString *param = nil;
//    if (useGet) {
    param = [NSString stringWithFormat:@"%g,%g", origin.coordinate.latitude, origin.coordinate.longitude];
//    } else {
        array = [NSMutableArray array];
        for (MKPointAnnotation *annotation in routeLocationsArray) {
            if (annotation == [routeLocationsArray firstObject])
                continue;
            CLLocationCoordinate2D coordinate = annotation.coordinate;
            NSDictionary *destinationDict = [NSDictionary dictionaryWithObjects:@[@(coordinate.latitude), @(coordinate.longitude)] forKeys:@[@"lat", @"lng"]];
            [array addObject:destinationDict];
        }
//    }
    
    [WebServicesManager connectWithType:WSConnectionTypeGoogleTraceroute singleParam:param jsonParam:[array JSONString] originLocation:CLLocationCoordinate2DZero destLocation:CLLocationCoordinate2DZero withObserver:self];
    
//    [WebServicesManager connectWithType:(WSConnectionTypeGoogleTraceroute + type) singleParam:nil jsonParam:nil originLocation:origin.coordinate destLocation:destination.coordinate withObserver:self];
}

- (StoreAnnotation*) getAnnotationFromMapWithLocation:(StoreLocation*)location {
    for ( id annotation in [self.storeMapView annotations]) {
        if ([annotation isKindOfClass:[StoreAnnotation class]]) {
            if ([[(StoreAnnotation*)annotation location]isEqualToLocation: location])
                return annotation;
        }
    }
    return nil;
}

- (void)updateLocationsInMapWithLocation:(CLLocationCoordinate2D)locationCoordinate andSpan:(MKCoordinateSpan)span{
    
    if (isInRouteMode && ([[self.storeMapView annotations] count] > 2 || [[self.storeMapView annotations] count] < 2)){
        NSArray *annotations = [self.storeMapView annotations];
        NSMutableSet *annotationsToKeep = [NSMutableSet setWithObject:self.routeAnnotation];
        [annotationsToKeep addObjectsFromArray:self.directionsAnnotationsArray];
        NSMutableSet *currentAnnotations = [NSMutableSet setWithArray:annotations];
        if (![currentAnnotations containsObject:self.routeAnnotation]) {
            [self.storeMapView addAnnotation:self.routeAnnotation];
        }
        [currentAnnotations minusSet:annotationsToKeep];
        [self.storeMapView removeAnnotations:[currentAnnotations allObjects]];
        return;
    }
    if (isInRouteMode) return;
    NSArray *array = [self getLocationsNearLocation:locationCoordinate andSpan:span inMeters:NO];
    if (array == nil) return;
    NSArray *annotations = [self.storeMapView annotations];
	NSMutableSet *currentAnnotations = [NSMutableSet setWithArray:annotations];
	NSMutableSet *annotationsToKeep = [NSMutableSet set];//[NSMutableSet setWithArray:arrayNearMe];
	StoreAnnotation *annotation = nil;
	BOOL wasFound = NO;
	NSMutableArray *reasonsToAdd = [NSMutableArray array];
    
	for(annotation in annotations) {
		if([annotation isKindOfClass:[StoreAnnotation class]]) 
		{
            NSInteger i = 0;
			for (i = 0; i < [array count]; i++) {
				if ([[array objectAtIndex:i] isEqualToLocation:annotation.location]) {
					[annotationsToKeep addObject:annotation];
					break;
				}
			}
		} else {
			[annotationsToKeep addObject:annotation];
		}
	}
	
	for (StoreLocation *location in array) {
		wasFound = NO;
		for(annotation in annotations) {
			
			if([annotation isKindOfClass:[StoreAnnotation class]]) 
			{
				if ([location isEqualToLocation:annotation.location]) {
					wasFound = YES;
					break;
				}
			}
		}	
		if (!wasFound) {
			[reasonsToAdd addObject:location];
		}
	}
	
    if (self.routeAnnotation) {
        
        if (![currentAnnotations containsObject:self.routeAnnotation]) {
            [self.storeMapView addAnnotation:self.routeAnnotation];
        }
        if ([self.directionsAnnotationsArray count] > 0) {
            [annotationsToKeep addObjectsFromArray:self.directionsAnnotationsArray];
        }
        [annotationsToKeep addObject:self.routeAnnotation];
    }
	
	[currentAnnotations minusSet:annotationsToKeep];
    
	[self.storeMapView removeAnnotations:[currentAnnotations allObjects]];
	
    [self.annotationsPool addObjectsFromArray:[currentAnnotations allObjects]];
    
	for (StoreLocation *location in reasonsToAdd) {
		
		StoreAnnotation *annotation = [self.annotationsPool anyObject];
        if (annotation) {
            [annotation updateLocation:location];
            [self.annotationsPool removeObject:annotation];
        } else {
            annotation = [[StoreAnnotation alloc] initWithStoreLocation:location];
        }
		[self.storeMapView addAnnotation:annotation];
	}
    if (!self.currentMapLocations) {
        self.currentMapLocations = [NSMutableArray array];
    }
    //NSLog(@"Otra vez:");
}

#pragma mark - StoreLocationConfigurationDelegate

- (void)storeLocationConfiguration:(StoreLocatorConfigurationViewController *)configurationController optionSelectedAtIndex:(NSInteger)index{
    switch ([configurationController type]) {
//        case TableTypeConfiguration:
//            currentDistanceConf = [[self.distances objectAtIndex:index] intValue];
//            self.currentMapLocations = [NSMutableArray arrayWithArray:[self getLocationsNearLocation:userLocation andSpan:self.storeMapView.region.span inMeters:YES]];
//            [self updateCoordinatesInARController];
//            break;
        case TableTypeDirections:
        {
            
            if (currentSegmentIndex != index && self.segmentLine) {
                [self.storeMapView removeOverlay:self.segmentLine];
                [self.segmentLineView removeFromSuperview];
                self.segmentLineView = nil;
                self.segmentLine = nil;
            } else if (currentSegmentIndex == index) {
                return;
            }
            if (currentSegmentIndex >= 0) {
                [[self.directionsArray objectAtIndex:currentSegmentIndex] removeObjectForKey:@"selected"];
            }
            currentSegmentIndex = index;
            [[self.directionsArray objectAtIndex:currentSegmentIndex] setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
            SLRoute *route = nil;
            route = [[directionsArray objectAtIndex:currentSegmentIndex] objectForKey:@"route"];
            self.segmentLine = [MKPolyline polylineWithPoints:route.points count:route.count];
            [self.storeMapView addOverlay:self.segmentLine];
            [self zoomInOnRouteSegment:route.points count:route.count];
            [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController = nil;
        }
            break;
        case TableTypeNearMe:
        case TableTypeConfiguration:
        {
            StoreLocation *location = [self.currentMapLocations objectAtIndex:index];
            //self.routeAnnotation = [self getAnnotationFromMapWithLocation:location];
            //[self.popoverController dismissPopoverAnimated:YES];
            [configController dismissFromScreen];
            [self showDetailOfLocation:location];
//            StoreLocatorDetailViewController *detailviewController = [[[StoreLocatorDetailViewController alloc] initWithLocation:location delegate:self] autorelease];
//            [self.navigationController pushViewController:detailviewController animated:YES];
        }
            break;
        case TableTypeStoresCatalog:
        {
            //[self setMask:indexPath.row toValue:![self isTypeEnabled:indexPath.row]];
            [self toggleStoreFilter:[[self.enabledStores objectAtIndex:index] intValue]];
            self.currentMapLocations = [NSMutableArray arrayWithArray:[self getLocationsNearLocation:userLocation andSpan:self.storeMapView.region.span inMeters:YES]];
            [self updateCoordinatesInARController];
            [self updateLocationsInMapWithLocation:self.storeMapView.centerCoordinate andSpan:self.storeMapView.region.span];
        }   
            break;
        default:
            break;
    }
    
}

- (void)configViewControllerDidShow:(StoreLocatorConfigurationViewController *)configurationController {
    //configController = configurationController;
}

- (void)configViewControllerDidDismiss:(StoreLocatorConfigurationViewController *)configurationController {
    if (configController == configurationController) {
        configController = nil;
    }
}

- (void)configViewController:(StoreLocatorConfigurationViewController *)configurationController didChangeMaxNearStores:(NSInteger)stores {
    currentMaxStores = stores;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currentMaxStores] forKey:@"currentMaxStores"];
    [self updateLocationsInMapWithLocation:self.storeMapView.centerCoordinate andSpan:self.storeMapView.region.span];
}

- (void)configViewController:(StoreLocatorConfigurationViewController *)configurationController didChangeDistanceRange:(NSInteger)kilometers {
    currentDistanceConf = kilometers * 1000;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currentDistanceConf] forKey:@"currentDistanceConf"];
    self.currentMapLocations = [NSMutableArray arrayWithArray:[self getLocationsNearLocation:userLocation andSpan:self.storeMapView.region.span inMeters:YES]];
    [self updateCoordinatesInARController];
    configurationController.dataSource = self.currentMapLocations;
}
#pragma  mark - WEPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController {
    self.popoverController = nil;
}

#pragma mark - ARViewDataSource

- (void)arViewControllerReady:(ARViewController*)viewController {
    [self updateCoordinatesInARController];
}

#pragma mark - ARViewDelegate

- (void)updateView:(UIView *)view withCoordinate:(ARCoordinate *)coordinate {
    ARLocationView *locationView = (ARLocationView*)view;
    UILabel *label = locationView.distanceLabel;
    ARGeoCoordinate *geoCoordinate = (ARGeoCoordinate*)coordinate;
    if (geoCoordinate.distance > 500) {
        label.text = [NSString stringWithFormat:@"%.2f km",(geoCoordinate.distance/1000)];
    } else {
        label.text = [NSString stringWithFormat:@"%d m",(int)geoCoordinate.distance];
    }
}

- (UIView*)viewForCoordinate:(ARCoordinate *)coordinate {
    
    ARLocationView *locationView = (ARLocationView*)[[[NSBundle mainBundle] loadNibNamed:@"ARLocationView" owner:self options:nil] objectAtIndex:0];
	
	UILabel *titleLabel = locationView.titleLabel;
    
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.text = coordinate.title;
    
    titleLabel.layer.cornerRadius = 5;
    
	UIImageView *pointView = locationView.imageView;
    ARGeoCoordinate *geoCoordinate = (ARGeoCoordinate*)coordinate;
    switch (geoCoordinate.type) {
        case BusinessIDSupercenter:
            pointView.image = [UIImage imageNamed:@"iconoWalmart.png"];
            titleLabel.textColor = [UIColor colorWithRed:0.0 green:0.49 blue:0.76 alpha:1.0];
            break;
        case BusinessIDSuperama:
            pointView.image = [UIImage imageNamed:@"iconoSuperama.png"];
            break;
        case BusinessIDSams:
            pointView.image = [UIImage imageNamed:@"iconoSams.png"];
            titleLabel.textColor = [UIColor colorWithRed:0.39 green:0.62 blue:0.25 alpha:1.0];
            break;
    }
    
    pointView.tag = 2;
    
    UILabel *label = locationView.distanceLabel;
    
    label.layer.cornerRadius = 5;       
    
    if (geoCoordinate.distance > 500) {
        label.text = [NSString stringWithFormat:@"%.2f km",(geoCoordinate.distance/1000)];
    } else {
        label.text = [NSString stringWithFormat:@"%d m",(int)geoCoordinate.distance];
    }
    
    [locationView setDelegate:self];

    return locationView;
}

- (void)setDetailViewInfo:(UIView*)_detailView forCoordinate:(ARCoordinate*)coordinate {
    ARDetailView *arView = (ARDetailView*)_detailView;
    ARGeoCoordinate *geoCoordinate = (ARGeoCoordinate*)coordinate;
    StoreLocation *focusedLocation = nil;
    for (StoreLocation *location in self.currentMapLocations) {
        if (location.storeID == geoCoordinate.identifier) {
            focusedLocation = location;
            break;
        }
    }
    self.detailLocation = focusedLocation;
    StoreType storeType = [StoreAnnotation getTypeFromLocationType:focusedLocation.type];
    arView.titleLabel.text = [[StoreAnnotation getStoreNameFromType:storeType] stringByAppendingFormat:@" %@", focusedLocation.storeName];
    arView.detailLabel.text = focusedLocation.storeAddress;
    arView.imageView.image = [StoreAnnotation getImageFromType:storeType];
    arView.hoursLabel.text = [NSString stringWithFormat:@"Horario de atención: %@", focusedLocation.storeSchedule];
    NSString *distance = nil;
    if (focusedLocation.distanceInMeters > 500) {
        distance = [NSString stringWithFormat:@"%.2f km",(focusedLocation.distanceInMeters/1000)];
    } else {
        distance = [NSString stringWithFormat:@"%d m",(int)focusedLocation.distanceInMeters];
    }
    arView.distanceLabel.text = [NSString stringWithFormat:@"Distancia: %@", distance];
}

- (void)updateCoordinatesInARController {
    NSMutableArray *tempLocations = [NSMutableArray array];
    for (StoreLocation *location in self.currentMapLocations) {
        
        CLLocation *tempLocation = [[CLLocation alloc] initWithCoordinate:location.coordinate altitude:2240 horizontalAccuracy:1.0 verticalAccuracy:1.0 timestamp:[NSDate date]];
        ARGeoCoordinate *geoCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
        geoCoordinate.title = location.storeName;
        geoCoordinate.type = location.type;
        geoCoordinate.identifier = (int)location.storeID;
        [tempLocations addObject:geoCoordinate ];
    }
    [self.arGeoViewController updateCoordinates:tempLocations];
}

- (void)detailView:(UIView*)detailView buttonPressed:(UIButton*)button {
    if (self.detailLocation) {
        [self showLoadingView];
        RouteType type = (RouteType)button.tag;
        self.routeAnnotation = [self getAnnotationFromMapWithLocation:detailLocation];
        if (!self.routeAnnotation)
            self.routeAnnotation = [[StoreAnnotation alloc] initWithStoreLocation:detailLocation];
        [WebServicesManager connectWithType:(WSConnectionTypeGoogleTraceroute + type) singleParam:nil jsonParam:nil originLocation:userLocation destLocation:self.routeAnnotation.location.coordinate withObserver:self];
    }
}

- (void)dismissARView {
    UIBarButtonItem *item = [self.bottomBar.items objectAtIndex:[self.bottomBar.items count] - 2];
    UIButton *button = (UIButton*)item.customView;
    [self.arGeoViewController dismissCamera];
    [self.arGeoViewController.view removeFromSuperview];
    self.arGeoViewController = nil;
    [button setImage:[UIImage imageNamed:@"btnBrujula_barraInferior"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"btnBrujula_barraInferior_press"] forState:UIControlStateHighlighted];
    self.addressView.frame = CGRectMake(75, 1, 240, 42);
    self.navigationItem.leftBarButtonItem.customView.frame = CGRectMake(0, 0, 42, 30);
    [(UIBarButtonItem*)[self.bottomBar.items objectAtIndex:6] customView].hidden = NO;
    [(UIBarButtonItem*)[self.bottomBar.items objectAtIndex:7] customView].hidden = NO;

    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusNotDetermined) {
        if ([manager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS8+
            // Sending a message to avoid compile time error
            [manager requestAlwaysAuthorization];
//
//            self.storeMapView.showsUserLocation = YES;
            
        }
    } else if (status == kCLAuthorizationStatusAuthorizedAlways ) {
        self.storeMapView.showsUserLocation = YES;
    }
}

- (IBAction)destinationsButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"GoToDestinations" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"GoToDestinations"]) {
        MPRouteDestinationsViewcontroller *controller =  (MPRouteDestinationsViewcontroller*)segue.destinationViewController;
        controller.delegate = self;
    }
}
    
- (void)getRouteWithDestinations:(NSArray *)destinationsArray {
    __block NSArray *array = destinationsArray;
    [self.navigationController popViewControllerAnimated:YES];
    double delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self resetMapAnnotations];
        [routeLocationsArray removeAllObjects];
        for (MPSearchResult *result in array) {
            MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
            annot.coordinate = result.location;
            annot.title = result.resultName;
            [self.storeMapView addAnnotation:annot];
            
            if (!routeLocationsArray) {
                routeLocationsArray = [[NSMutableArray alloc] init];
            }
            [routeLocationsArray addObject:annot];
        }
        [self getRouteWithType:RouteTypeCar];
    });

}
    
- (void)initSpeechSystem {
    self.speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    [self.speechSynthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryWord];

}
    
- (void)speak:(NSString *)text {
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"es-MX"];
    utterance.rate = AVSpeechUtteranceMinimumSpeechRate + AVSpeechUtteranceMinimumSpeechRate / 2;
    [self.speechSynthesizer speakUtterance:utterance];
}
    
- (void)resetMapAnnotations {
    [self.storeMapView removeOverlay:self.routeLine];
    [self.storeMapView removeAnnotations:self.directionsAnnotationsArray];
    self.routeLine = nil;
    [self.directionsAnnotationsArray removeAllObjects];
    [self.directionsArray removeAllObjects];
    northEastPoint = MKMapPointMake(0, 0);
    southWestPoint = MKMapPointMake(0, 0);
}
    
@end


