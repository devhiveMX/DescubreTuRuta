//
//  SlideView.h
//  Esquire
//
//  Created by Valentina Sautto on 8/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum SLIDEOPTIONS{
	UP,
	DOWN,
	LEFT,
	RIGHT,
}SlideOptions;

@class SlideView;

@protocol SlideViewDelegate <NSObject>
@optional
- (void)slideViewDidFinishSliding:(SlideView*)_slideView;
@end


@interface SlideView : UIView {
	bool hide;
    id delegate;
	SlideOptions slideTo;
	CGRect initialPositions;
	CGFloat interval;
	CGFloat customOffset;
	bool customOffsetAvailable;
	CGRect originalFrame;
	CGRect newFrame;
}

- (void)slide;
- (void)slideIn;
- (void)slideOut;
- (void)setInterval:(CGFloat)_interval;
- (void)setSlideToWithoutAnimation:(SlideOptions)st interval:(CGFloat)_interval;
- (void)animationDidFinish;

@property (assign) IBOutlet id delegate;
@property (assign) bool hide;
@property (nonatomic, assign) SlideOptions slideTo;
@property (assign) CGFloat interval;
@property (nonatomic, assign) CGFloat customOffset;


@end
