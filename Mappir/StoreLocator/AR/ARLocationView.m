

#import "ARLocationView.h"
#import <QuartzCore/QuartzCore.h>

@interface ARLocationView()
//@property (nonatomic, assign) BOOL highlighted;
@end

@implementation ARLocationView

@synthesize distanceLabel;
@synthesize titleLabel;
@synthesize imageView;
@synthesize highlightedImage;
@synthesize actionButton;
@synthesize isAnimating;
@synthesize delegate;
@synthesize highlighted;
@synthesize currentScaleFactor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 10;
}

- (void)dealloc {
    self.distanceLabel = nil;
    self.titleLabel = nil;
    self.imageView = nil;
    self.actionButton = nil;
    self.highlighted = nil;
}

- (void)setHighlighted:(BOOL)_highlighted {
    if (_highlighted) {
        [UIView beginAnimations:nil context:nil]; 
        [UIView setAnimationDuration:0.1];
        [self setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:nil context:nil]; 
        [UIView setAnimationDuration:0.1];
        [self setTransform:CGAffineTransformMakeScale(currentScaleFactor, currentScaleFactor)];
        [UIView commitAnimations];
        
    }
    highlighted = _highlighted;
    self.highlightedImage.highlighted = highlighted;
//    [self animateHighlighted];
}

- (void)setTransform:(CGAffineTransform)transform {
    if (![self highlighted]) {
        [super setTransform:transform];
    }
}

- (void)animateHighlighted {
    
    
}

- (void)animateHighlightOnTouch {
//    [self setHidden:NO];
    xScaleBeforeAnimation = self.transform.a;
    yScaleBeforeAnimation = self.transform.d;
#if DEBUG_MODE
    NSLog (@"Transform: %@",NSStringFromCGAffineTransform(self.transform));
#endif
    isAnimating = YES;
    [UIView beginAnimations:@"highlight" context:NULL]; 
    [UIView setAnimationDuration:0.1];
//    [self.imageView setTransform:CGAffineTransformMakeScale(currentScaleFactor + 0.3, currentScaleFactor + 0.3)];
    [self setTransform:CGAffineTransformMakeScale(currentScaleFactor + 0.2, currentScaleFactor + 0.2)];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:@"highlight"]) {
        [UIView beginAnimations:@"highlight2" context:nil]; 
        [UIView setAnimationDuration:0.1];
//        CGAffineTransform transform = CGAffineTransformMakeTranslation(10, 12);
//        transform = CGAffineTransformScale(transform, 0.8, 0.8);
//        [self.imageView setTransform:CGAffineTransformMakeScale(currentScaleFactor - 0.3, currentScaleFactor - 0.3)];
        [self setTransform:CGAffineTransformMakeScale(currentScaleFactor - 0.2, currentScaleFactor - 0.2)];
//        [self setTransform:transform];
        [UIView setAnimationDelegate:self];
        [UIView commitAnimations];
    } else if ([animationID isEqualToString:@"highlight2"]) {
        [UIView beginAnimations:@"highlight3" context:nil]; 
        [UIView setAnimationDuration:0.1];
//        [self.imageView setTransform:CGAffineTransformMakeScale(currentScaleFactor, currentScaleFactor)];
        [self setTransform:CGAffineTransformMakeScale(currentScaleFactor, currentScaleFactor)];
        [UIView setAnimationDelegate:self];
        [UIView commitAnimations];
    } else if ([animationID isEqualToString:@"highlight3"]) {
        isAnimating = NO;
    }
}

- (IBAction)buttonPressed {
//    [self animateHighlightOnTouch];
    [self.superview bringSubviewToFront:self];
    self.highlighted = !self.highlighted;
    if ([self.delegate respondsToSelector:@selector(viewPressed:)]) {
        [self.delegate viewPressed:self];
    }
    NSNotification* notification = [NSNotification notificationWithName:@"locationFocused"
                                                                 object:self
                                                               userInfo:nil];
//    [NSDictionary dictionaryWithObjectsAndKeys:[[connection.responseData copy] autorelease],@"data",[NSNumber numberWithInt:connection.type], @"type", nil]
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
}

@end
