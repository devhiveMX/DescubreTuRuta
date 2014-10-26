

#import <UIKit/UIKit.h>
#import "UIColor+RGB.h"

typedef enum {
    TableTypeNearMe = 0,
    TableTypeStoresCatalog,
    TableTypeDirections,
    TableTypeConfiguration,
}TableType;

@class StoreLocatorConfigurationViewController;
@class WEPopoverController;
@protocol StoreLocationConfigurationDelegate <NSObject>

- (void)storeLocationConfiguration:(StoreLocatorConfigurationViewController*)configurationController optionSelectedAtIndex:(NSInteger)index;
@optional
- (void)configViewControllerDidShow:(StoreLocatorConfigurationViewController*)configurationController;
- (void)configViewControllerDidDismiss:(StoreLocatorConfigurationViewController*)configurationController;
- (void)configViewController: (StoreLocatorConfigurationViewController*)configurationController didChangeMaxNearStores:(NSInteger)stores;
- (void)configViewController: (StoreLocatorConfigurationViewController*)configurationController didChangeDistanceRange:(NSInteger)kilometers;

@end


@interface StoreLocatorConfigurationViewController : UIViewController {
    NSArray *dataSource;
    NSMutableIndexSet *enabledFilters;
    TableType type;
    UITableView *nearStoresTableView;
}

@property (nonatomic, retain) NSArray *dataSource;
@property (nonatomic, retain) NSDictionary *extraInfo;
@property (nonatomic, retain) NSMutableIndexSet *enabledFilters;
@property (nonatomic, readonly) TableType type;
@property (nonatomic, assign) id<StoreLocationConfigurationDelegate> delegate;
@property (nonatomic, retain) WEPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UITableView *nearStoresTableView;
@property (nonatomic, retain) IBOutlet UITableView *directionsTableView;
@property (nonatomic, retain) IBOutlet UIView *directionsView;
@property (nonatomic, retain) IBOutlet UIView *nearView;
@property (nonatomic, retain) IBOutlet UILabel *distanceTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;
@property (nonatomic, retain) IBOutlet UILabel *storesLabel;
@property (nonatomic, retain) IBOutlet UISlider *distanceSlider;
@property (nonatomic, retain) IBOutlet UISlider *storesSlider;

- (id)initWithType:(TableType)_type dataSource:(NSArray*)_dataSource selectedItems:(NSIndexSet*)selItems delegate:(id<StoreLocationConfigurationDelegate>)_delegate;
- (BOOL)isIndexEnabled:(NSInteger)index;
- (void)toggleIndex:(NSInteger)index;
- (CGFloat)heightForDirectionsCell:(NSString *)text;

- (void)dismissFromScreen;
- (void)dismiss;
- (void)show;
@end
