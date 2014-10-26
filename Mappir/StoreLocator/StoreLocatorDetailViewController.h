

#import <UIKit/UIKit.h>
#import "WBaseViewController.h"

typedef enum {
    RouteTypeCar = 0,
    RouteTypeFoot,
}RouteType;
@class StoreLocation;
@class StoreLocatorDetailViewController;
@protocol StoreLocatorDetailDelegate <NSObject>
@optional
- (void)StoreLocatorDetail:(StoreLocatorDetailViewController*)detailViewController GetRouteWithType:(RouteType)type;
@end

@interface StoreLocatorDetailViewController : WBaseViewController {
    StoreLocation *location;
}
@property (nonatomic, retain) IBOutlet UIImageView *storeImageView;
@property (nonatomic, retain) IBOutlet UILabel *storeNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *storeAddressLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;
@property (nonatomic, retain) IBOutlet UILabel *userLocationAddressLabel;
@property (nonatomic, retain) IBOutlet UILabel *serviceHours;
@property (nonatomic, retain) StoreLocation *location;
@property (nonatomic, assign) id<StoreLocatorDetailDelegate> delegate;

- (id)initWithLocation:(StoreLocation *)aLocation delegate:(id<StoreLocatorDetailDelegate>)_delegate;

@end
