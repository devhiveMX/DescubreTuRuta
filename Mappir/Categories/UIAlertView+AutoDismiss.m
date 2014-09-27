//
//  UIAlertView+AutoDismiss.m
//  Superama1.5
//
//  Created by WALMEX3.0 _1 WALMART on 17/05/12.
//  Copyright (c) 2012 WALMART. All rights reserved.
//

#import "UIAlertView+AutoDismiss.h"

@implementation UIAlertView (AutoDismiss)
- (void)dismiss {
    [self dismissWithClickedButtonIndex:0 animated:YES];
}
@end
