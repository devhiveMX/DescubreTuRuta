//
//  CustomToolbar.h
//  WalmartApp
//
//  Created by WALMEX3.0 _1 WALMART on 17/10/11.
//  Copyright (c) 2011 Walmart Stores Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomToolbar : UIToolbar {
    UIImage *customImage;
}
@property (nonatomic, retain) UIImage *customImage;

- (id)initWithCustomImage:(UIImage *)image;
- (void)adjustFrameToButtons;

@end
