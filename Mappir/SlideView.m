//
//  SlideView.m
//  Esquire
//
//  Created by Valentina Sautto on 8/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SlideView.h"

@implementation SlideView

@synthesize hide, slideTo;
@synthesize delegate = _delegate;
@synthesize customOffset;
@synthesize interval;

#define DEFAULT_INTERVAL 0.5;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.hide = FALSE;
		interval = DEFAULT_INTERVAL;
		initialPositions = frame;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self slideOut];
    interval = DEFAULT_INTERVAL;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)dealloc {

}

#pragma mark -
#pragma mark methods

- (void) slide{
	if(self.hide){
		[self slideIn];
	}else {
		[self slideOut];
	}
	
}

- (void) slideIn {
	if (!self.hide) return;
	self.hide = NO;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:interval];
	[UIView setAnimationDelegate:self];
	switch (slideTo) {
		case LEFT:
			if (customOffsetAvailable)
				self.frame = CGRectMake(self.frame.origin.x - self.customOffset, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
			else
				self.frame = CGRectMake(self.frame.origin.x - self.customOffset, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
			break;
		case RIGHT:
			if (customOffsetAvailable)
				self.frame = CGRectMake(self.frame.origin.x + self.customOffset, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
			else
				self.frame = CGRectMake(self.frame.origin.x + self.customOffset, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
			break;
		case UP:
			if (customOffsetAvailable)
				self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.customOffset, self.frame.size.width, self.frame.size.height);
			else{
				//NSLog(@"-->%f %f %f %f",self.frame.origin.x, self.frame.origin.y - self.frame.size.height, self.frame.size.width, self.frame.size.height);
				self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.frame.size.height, self.frame.size.width, self.frame.size.height);
			}
			break;
		case DOWN:
			if (customOffsetAvailable)
				self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.customOffset, self.frame.size.width, self.frame.size.height);
			else
				self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height);
			break;
		default:
			break;
	}
	[UIView setAnimationDidStopSelector:@selector(animationDidFinish)];
	[UIView commitAnimations];	
}

- (void) slideOut {
	if (self.hide) return;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:interval];
	[UIView setAnimationDelegate:self];
	switch (slideTo) {
		case LEFT:
			if (customOffsetAvailable)
				self.frame = CGRectMake(self.frame.origin.x + self.customOffset, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
			else
				self.frame = CGRectMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
			break;
		case RIGHT:
			if (customOffsetAvailable)
				self.frame = CGRectMake(self.frame.origin.x - self.customOffset, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
			else
				self.frame = CGRectMake(self.frame.origin.x - self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
			break;
		case UP:
			if (customOffsetAvailable)
				self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.customOffset, self.frame.size.width, self.frame.size.height);
			else
				self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height);
			break;
		case DOWN:
			if (customOffsetAvailable)
				self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.customOffset, self.frame.size.width, self.frame.size.height);
			else
				self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.frame.size.height, self.frame.size.width, self.frame.size.height);
			break;
		default:
			break;
	}
	[UIView setAnimationDidStopSelector:@selector(animationDidFinish)];
	[UIView commitAnimations];	
	self.hide = YES;
}

- (void) setSlideTo:(SlideOptions)st{
	slideTo = st;
	switch (slideTo) {
		case LEFT:
			if (customOffsetAvailable)
				self.frame = CGRectMake(self.frame.origin.x + self.customOffset, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
			else
				self.frame = CGRectMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
			break;
		case RIGHT:
			if (customOffsetAvailable)
				self.frame = CGRectMake(self.frame.origin.x - self.customOffset, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
			else
				self.frame = CGRectMake(self.frame.origin.x - self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
			break;
		case UP:
			if (customOffsetAvailable)
				self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.customOffset, self.frame.size.width, self.frame.size.height);
			else
				self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height);
			break;
		case DOWN:
			if (customOffsetAvailable)
				self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.customOffset, self.frame.size.width, self.frame.size.height);
			else
				self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.frame.size.height, self.frame.size.width, self.frame.size.height);
			break;
		default:
			break;
	}
	hide = YES;
}

- (void)setCustomOffset:(CGFloat)offset {
	if (offset != 0)
	{
		customOffsetAvailable = YES;
	}
	else { 
		customOffsetAvailable = NO;
	}

	customOffset = offset;
}

- (void)setSlideToWithoutAnimation:(SlideOptions)st interval:(CGFloat)_interval {
	slideTo = st;
	[self setInterval:_interval];
}

- (void)animationDidFinish {
	if ([self.delegate respondsToSelector:@selector (slideViewDidFinishSliding:)]) {
		[self.delegate slideViewDidFinishSliding:self];
	}
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//[self slideOut];
}
@end
