//
//  MPAddingLocationsViewcontroller.h
//  Mappir
//
//  Created by Leonardo Cid on 12/10/14.
//  Copyright (c) 2014 Devhive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServicesManager.h"
#import "WEPopoverController.h"
#import "MPSearchResultsViewController.h"

@protocol MPRouteDestinationsDelegate <NSObject>

- (void)getRouteWithDestinations:(NSArray*)destinationsArray;

@end

@interface MPRouteDestinationsViewcontroller : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, WebServicesObserver, WEPopoverControllerDelegate, MPSearchResultsDataSource, MPSearchResultsDelegate> {
    NSMutableArray *destinationsArray;
    NSInteger currentSearchFieldIndex;
    BOOL canGetRoute;
    
}

@property (nonatomic, strong) WEPopoverController *popover;
@property (nonatomic, strong) NSTimer *searchTimer;
@property (nonatomic, weak) id <MPRouteDestinationsDelegate> delegate;


@end
