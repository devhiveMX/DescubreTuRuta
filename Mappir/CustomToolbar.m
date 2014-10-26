

#import "CustomToolbar.h"
#import "Definitions.h"

@implementation CustomToolbar
@synthesize customImage;


- (id)init {
    if (self = [super init]) {
        self.customImage = [UIImage imageNamed: DEFAULT_CUSTOM_BAR_IMAGE];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])
    {
        self.customImage = [UIImage imageNamed: DEFAULT_CUSTOM_BAR_IMAGE];
    }
    return self;
}

- (void)awakeFromNib {
    self.customImage = [UIImage imageNamed: DEFAULT_CUSTOM_BAR_IMAGE];
}

- (id)initWithCustomImage:(UIImage *)image {
    if (self = [self init]) {
        
    }
    return self;
}

- (void)adjustFrameToButtons {
    if ([self.items count] > 0) {
        CGRect aRect = self.frame;
        CGFloat width = 0;
        for (UIBarButtonItem *item in self.items) {
            if (item.customView) {
                width += item.customView.frame.size.width;
            }
        }
        aRect.size.width = width;
        self.frame = aRect;
    }
}

- (void)drawRect:(CGRect)rect {
    if (self.customImage)
        [self.customImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    else
        [super drawRect:rect];
}

@end
