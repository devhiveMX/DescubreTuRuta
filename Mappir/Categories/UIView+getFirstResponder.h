

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
