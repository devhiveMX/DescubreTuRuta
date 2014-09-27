//
//  UIViewController+GetButton.h
//  WalmartApp
//
//  Created by WALMEX3.0 _1 WALMART on 01/08/11.
//  Copyright 2011 Walmart Stores Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBaseViewController.h"

@class WEPopoverContainerViewProperties;
@class TicketMyListsViewController;
@class TicketListViewerViewController;


#define LOADING_VIEW_TAG    23
#define SPINNER_TAG         33
#define BG_TAG              43

@interface UIViewController (GetButton)

- (void)showLoadingView;
- (void)dismissLoadingView;
- (UIButton*)getButtonFromType:(SuperiorBarButtonType)Type;
- (void)popNavigationViewControllerAnimated;
- (void)popNavigationViewController;
- (BOOL)isMailValid:(NSString*)mailString;
- (id)getCodeMessageFromJSonObject:(id)object;
- (id)getValueFromJSonObject:(id)object forKey:(id)key;
- (void)cancelButtonPressed;
- (UIImage*)getImageFromStoreId:(StoreId)storeId isBlue:(BOOL)isBlue;

- (void)showDecisionAlertWithTitle:(NSString*)title message:(NSString*)message alertViewTag:(NSInteger)tag cancelButtonTitle:(NSString*)noButton okButtonTitle:(NSString *)okButton;
- (void)showAlertViewWithTitle:(NSString*)title message:(NSString *)message buttonTitle:(NSString*)buttonTitle;

- (void)logout;
- (void)goHome;

- (UIView *)keyView;
- (UIView *)getFirstResponder;
- (WEPopoverContainerViewProperties *)getContainerViewProperties;
@end
