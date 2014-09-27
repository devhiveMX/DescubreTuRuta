//
//  UIView+getFirstResponder.h
//  WalmartApp
//
//  Created by WALMEX3.0_1_WALMART on 22/09/11.
//  Copyright 2011 Walmart Stores Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIView (UIView_getFirstResponder)
- (UIView *)getFirstResponder;
- (void)setVisibleWithFadeAnimation:(BOOL)visible duration:(CGFloat)duration;
- (void)animateBlossom;
- (void)dismissBlossom;
- (UIView *)keyView;
- (void)attemptToRemoveSubViews;
+ (UIView*) loadInstanceOfViewFromNibWithOwner:(id)owner;
@end
