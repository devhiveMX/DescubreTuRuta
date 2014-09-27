//
//  ARLocationView.h
//  ARKitDemo
//
//  Created by WALMEX3.0 _1 WALMART on 07/08/12.
//  Copyright (c) 2012 Zac White. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARLocationView;
@protocol ARLocationViewDelegate <NSObject>
@optional
    - (void)viewPressed:(ARLocationView*)locationView;
@end
@protocol ARViewAwarenessDelegate <NSObject>
@optional
- (void)viewDidEnterFocus:(ARLocationView*)locationView;
- (void)viewDidLeaveFocus:(ARLocationView*)locationView;
@end
    
@interface ARLocationView : UIView {
    CGFloat xScaleBeforeAnimation;
    CGFloat yScaleBeforeAnimation;
    BOOL highlighted;
}

@property (nonatomic, readonly) BOOL isAnimating;
@property (nonatomic, assign) id<ARLocationViewDelegate> delegate;
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, assign) float currentScaleFactor;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIImageView *highlightedImage;
@property (nonatomic, retain) IBOutlet UIButton *actionButton;

- (void)animateHighlightOnTouch;

@end
