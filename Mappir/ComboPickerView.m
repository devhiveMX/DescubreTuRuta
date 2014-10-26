

#import "ComboPickerView.h"

@implementation ComboPickerView
@synthesize toolbar;
@synthesize picker;
@synthesize delegate;
@synthesize activeObject;
@synthesize isShowing;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)buttonPressed:(id)sender {
    
    NSInteger tag = 0;
    
    if ([sender isKindOfClass:[UIButton class]]) {
        tag = [(UIButton*)sender tag]; 
    } else if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        tag = [(UIBarButtonItem*)sender tag];
    }
    if (tag == 1) {
        [delegate ComboPickerDidCancelSelection:self];

    } else if (tag == 2) {
        [delegate ComboPicker:self didSelectIndex:[picker selectedRowInComponent:0] activeObject:self.activeObject];
    }
    [self dismiss];
}

- (void)dismiss {
    if (!isShowing) return;
    if ([self.delegate respondsToSelector:@selector(ComboPickerWillDismiss:)]) {
        [self.delegate performSelector:@selector(ComboPickerWillDismiss:) withObject:self];
    }
    CGRect superViewRect = [self.superview frame];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    CGRect rect = self.frame;
    rect.origin.y = superViewRect.size.height;
    self.frame = rect;
    [UIView commitAnimations];
    isShowing = NO;
}

- (void)showWithActiveObject:(id)object {
    
    self.activeObject = object;
    [self.picker reloadAllComponents];
    NSInteger components = [delegate numberOfComponentsInComboPickerView:self withActiveObject:self.activeObject];
    NSInteger i;
    for (i = 0; i < components; i++) {
        if ([delegate respondsToSelector:@selector(ComboPickerView:initialSelectedRowforComponent:)]) {
            [self.picker selectRow:[delegate ComboPickerView:self initialSelectedRowforComponent:i] inComponent:i animated:NO];
        } else {
            [self.picker selectRow:0 inComponent:i animated:NO];
        }
    }
    
    
    if (isShowing) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(ComboPickerWillShow:withActiveObject:)]) {
        [self.delegate performSelector:@selector(ComboPickerWillShow:withActiveObject:) withObject:self withObject:self.activeObject];
    }
    isShowing = YES;
    [self.superview bringSubviewToFront:self];
    CGRect superViewRect = [self.superview frame];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.35];
    CGRect rect = self.frame;
    rect.origin.y = superViewRect.size.height - rect.size.height;
    self.frame = rect;
    [UIView commitAnimations];
}

- (void)setDelegate:(id<UIPickerViewDelegate,UIPickerViewDataSource,ComboPickerViewDelegate>)_delegate {
    delegate = _delegate;
    self.picker.delegate = self;
    self.picker.dataSource = self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [delegate ComboPickerView:self numberOfRowsInComponent:component activeObject:self.activeObject];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [delegate numberOfComponentsInComboPickerView:self withActiveObject:self.activeObject];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [delegate ComboPickerView:self titleForRow:row forComponent:component activeObject:self.activeObject];
}

@end
