

#import "UIAlertView+AutoDismiss.h"

@implementation UIAlertView (AutoDismiss)
- (void)dismiss {
    [self dismissWithClickedButtonIndex:0 animated:YES];
}
@end
