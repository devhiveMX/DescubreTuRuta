

#import <UIKit/UIKit.h>

@interface CustomToolbar : UIToolbar {
    UIImage *customImage;
}
@property (nonatomic, retain) UIImage *customImage;

- (id)initWithCustomImage:(UIImage *)image;
- (void)adjustFrameToButtons;

@end
