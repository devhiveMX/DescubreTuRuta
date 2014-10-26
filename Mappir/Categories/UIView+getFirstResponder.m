

#import "UIView+getFirstResponder.h"


@implementation UIView (UIView_getFirstResponder)
- (UIView *)getFirstResponder
{
    if (self.isFirstResponder) {        
        return self;     
    }
    
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView getFirstResponder];
        
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    
    return nil;
}

- (void)setVisibleWithFadeAnimation:(BOOL)visible duration:(CGFloat)duration{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [self setAlpha:(float)visible];
    [UIView commitAnimations];
}

- (void)animateBlossom {
    [self setHidden:NO];
    [UIView beginAnimations:@"blossom1" context:NULL]; 
    [UIView setAnimationDuration:0.15];
    [self setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

- (void)dismissBlossom {
    [UIView beginAnimations:@"dismissBlossom" context:NULL]; 
    [UIView setAnimationDuration:0.15];
    [self setTransform:CGAffineTransformMakeScale(0.01, 0.01)];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:@"blossom1"]) {
        [UIView beginAnimations:@"blossom2" context:nil]; 
        [UIView setAnimationDuration:0.10];
        [self setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
        [UIView setAnimationDelegate:self];
        [UIView commitAnimations];
    } else if ([animationID isEqualToString:@"blossom2"]) {
        [UIView beginAnimations:nil context:nil]; 
        [UIView setAnimationDuration:0.15];
        [self setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        [UIView setAnimationDelegate:nil];
        [UIView commitAnimations];
    } else if ([animationID isEqualToString:@"dismissBlossom"]) {
        [self setHidden:YES];
    }
}

+(UIView*) loadInstanceOfViewFromNibWithOwner:(id)owner { 
    UIView *result = nil; 
    NSArray* elements = [[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner: owner options: nil]; 
    for (id anObject in elements) { 
        if ([anObject isKindOfClass:[self class]]) { 
            result = anObject; 
            break; 
        } 
    } 
    return result; 
}

- (UIView *)keyView {
	UIWindow *w = [[UIApplication sharedApplication] keyWindow];
	if (w.subviews.count > 0) {
		return [w.subviews objectAtIndex:0];
	} else {
		return w;
	}
}

- (void)attemptToRemoveSubViews {
    [[self subviews] makeObjectsPerformSelector:@selector(attemptToRemoveSubViews)];
    [self removeFromSuperview];
}
@end
