

#import <UIKit/UIKit.h>
#import "ComboPickerView.h"
#import "WEPopoverController.h"
#import "UIAlertView+AutoDismiss.h"

@class WEPopoverContainerViewProperties;
@class TicketMyListsViewController;
@class TicketListViewerViewController;

typedef enum {
    SuperiorBarButtonBack,
    SuperiorBarButtonHomeSquare,
    SuperiorBarButtonRoute,
    //Store Locator
    SuperiorBarButtonSLMap,
    SuperiorBarButtonSLStoresType,
    SuperiorBarButtonSLStoresNearMe,
    SuperiorBarButtonSLDirections,
    SuperiorBarButtonSLMapType,
    SuperiorBarButtonSLMyLocation,
    SuperiorBarButtonSLConfiguration,
}SuperiorBarButtonType;

typedef enum {
    StoreIDNoStore = 0,
    StoreIDBodegaAurrera,
    StoreIDSamsClub,
    StoreIDSuperama,
    StoreIDSuperCenter,
    StoreIDSuburbia,
    StoreIDVips,
    StoreIDCustomList,
    StoreIDElPorton = 9,
}StoreId;

typedef enum { 
    ListTypeNoType = -1,
    ListTypeMyLists,
    ListTypeMyOrders,
    ListTypeShoppingCart,
    ListTypeSearch,
    ListTypeSession,
}ListType;

typedef enum {
    TicketListAVTypeNone,
    TicketListAVTypeName,
    TicketListAVTypeTelephone,
    TicketListAVTypePhoneNotValid,
    TicketListAVTypeNameNotValid,
    TicketListAVTypeNewList,
    TicketListAVTypeRenameList,
    TicketListAVTypeBack,
    TicketListAVTypeHome,
    TicketListAVTypeLogOut,
    TicketListAVTypeOpenList,
    TicketListAVTypeNewListConfirm,
    TicketListAVTypePendingAddToList,
    TicketListAVTypeBuy,
    TicketListAVTypeMenuCategories,
    TicketListAVTypeMenuMyLists,
    TicketListAVTypeMenuMyOrders,
    TicketListAVTypeShoppingCart,
    TicketListAVTypeAddItemsAfterUpdate,
    TicketListAVTypeUserNotInSession = -100,
}TicketListAVType;

typedef enum {
    DeviceSimulator,
    DeviceiPhone1,
    DeviceiPhone3G,
    DeviceiPhone3GS,
    DeviceiPhone4,
    DeviceiPhone4S,
    DeviceiPhone5,
    DeviceiPod1stGen,
    DeviceiPod2ndGen,
    DeviceiPod3rdGen,
    DeviceiPod4thGen,
    DeviceiPod5thGen,
    DeviceiPad1,
    DeviceiPad2Wifi,
    DeviceiPad2GSM,
    DeviceiPad2CDMA,
    DeviceiPad2New,
    DeviceiPadMiniWifi,
    DeviceiPadMiniGSM,
    DeviceiPad3Wifi,
    DeviceiPad3GSM,
    DeviceiPad3CDMA,
    DeviceUnknown,
} Device;

typedef enum {
    SessionMenuHome = 0,
    SessionMenuMyAccount,
    SessionMenuChat,
    SessionMenuTermsAndConditions,
    SessionMenuLogout,
} SessionMenuEntries;

#define DATE_FORMAT @"EEE, dd MMM yyyy HH:mm:ss zzz"
#define DATE_FORMAT_DISPLAY @"dd/MMM/yyyy"

#define LOADING_VIEW_TAG    23
#define SPINNER_TAG         33
#define BG_TAG              43
#define ADD_TO_LIST_VIEW    53
#define LOADING_IMAGE_TAG   99

@interface WBaseViewController : UIViewController <ComboPickerViewDelegate, WEPopoverControllerDelegate>{
    ComboPickerView *comboPickerView;   
    ListType fromListType;
    NSInteger initialRowForComboPickerView;
}
@property (nonatomic, retain) ComboPickerView *comboPickerView;
@property (nonatomic, retain) IBOutlet UILabel *sessionLabel;
@property (nonatomic, retain) IBOutlet UILabel *storeLabel;
@property (nonatomic, retain) UIButton *accountButton;
@property (nonatomic, retain) UIToolbar *listToolBar;
@property (nonatomic, retain) UIButton *myListsButton;
@property (nonatomic, retain) UIButton *myOrdersButton;
@property (nonatomic, retain) UIButton *myShoppingCart;
@property (nonatomic, assign) ListType fromListType;
@property (nonatomic, retain) WEPopoverController *popoverController;
@property (nonatomic, retain) UIButton *numberPadDoneButton;
@property (nonatomic, assign) BOOL canRotate;
@property (nonatomic, retain) IBOutlet UIImageView *bgImage;


- (void)showLoadingView;
- (void)dismissLoadingView;
- (UIButton*)getButtonFromType:(SuperiorBarButtonType)Type;
- (void)popNavigationViewControllerAnimated;
- (void)popNavigationViewController;
- (id)getCodeMessageFromJSonObject:(id)object;
- (id)getValueFromJSonObject:(id)object forKey:(id)key;
- (IBAction)cancelButtonPressed;
- (UIImage*)getImageFromStoreId:(StoreId)storeId isBlue:(BOOL)isBlue;

- (void)showDecisionAlertWithTitle:(NSString*)title message:(NSString*)message alertViewTag:(NSInteger)tag cancelButtonTitle:(NSString*)noButton okButtonTitle:(NSString *)okButton;
- (UIAlertView *)showAlertViewWithTitle:(NSString*)title message:(NSString *)message buttonTitle:(NSString*)buttonTitle;

- (void)goToLoginScreen;
- (void)logout;
- (void)goHome;

- (UIView *)keyView;
- (UIView *)getFirstResponder;
- (WEPopoverContainerViewProperties *)getContainerViewProperties;
- (void)loginAgain;

- (void)configureToolBarWithselector:(SEL)function;
- (void)configureBackButtonWithSelector:(SEL)backFunction;
- (IBAction)typeOfListPressed:(id)sender;
- (void)activateKeyboardObserver;
- (void)removeKeyboardObserver;
- (void)keyboardWillShow:(NSNotification *)note;
- (NSString *)formattedStringFromDate:(NSDate*)date usingFormat:(NSString *)dateFormat;
- (NSDate*)dateFromString:(NSString*)dateAsString withFormat:(NSString*)format;

-(NSString *)getWeightValueForIndex:(NSInteger)index withStep:(CGFloat)step;

- (NSError *)googleAnalyticsTrackEvent:(NSString*)event action:(NSString*)action label:(NSString*)label value:(NSInteger)value;
- (BOOL)shouldResizeAccordingToResolution;


+  (Device)deviceModelName;
@end
