

#import "WBaseViewController.h"
#import "UIColor+RGB.h"
#import "WSConnection.h"
#import "WebServicesManager.h"
#import "UIView+getFirstResponder.h"
#import "WEPopoverContainerView.h"
#import "NSObject+IsNullOrNil.h"
#import "NSString+IsNumber.h"
#import "Definitions.h"
#import <sys/utsname.h>

@implementation WBaseViewController
@synthesize comboPickerView;
@synthesize sessionLabel;
@synthesize storeLabel;
@synthesize accountButton;
@synthesize listToolBar;
@synthesize myListsButton;
@synthesize myOrdersButton;
@synthesize myShoppingCart;
@synthesize fromListType;
@synthesize popoverController;
@synthesize numberPadDoneButton;
@synthesize canRotate;
@synthesize bgImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    canRotate = NO;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

//Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)dealloc {
    [[self.view subviews] makeObjectsPerformSelector:@selector(attemptToRemoveSubViews)];
    self.comboPickerView = nil;
    self.accountButton = nil;
    [self.listToolBar setItems:nil];
    self.listToolBar = nil;
    self.myListsButton = nil;
    self.myOrdersButton = nil;
    self.myShoppingCart = nil;
    self.sessionLabel = nil;
    [self.popoverController dismissPopoverAnimated:NO];
    self.popoverController = nil;
    [self.numberPadDoneButton removeFromSuperview];
    self.numberPadDoneButton = nil;
    self.bgImage = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.titleView = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (!canRotate)
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else
        return YES;
}

- (BOOL)shouldAutorotate {
    return canRotate;
}

- (NSUInteger)supportedInterfaceOrientations {
    if (!canRotate) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    CGRect navigationToolbarFrame = self.navigationController.navigationBar.frame;
//    CGRect customToolbarFrame = CGRectOffset(navigationToolbarFrame, 0.0, navigationToolbarFrame.size.height);
//    [UIView animateWithDuration:duration animations:^{
//        self.listToolBar.frame = customToolbarFrame;     
//    }];
}


#pragma mark - custom 

- (UIButton*)getButtonFromType:(SuperiorBarButtonType)Type {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = nil;
    UIImage *imageOn = nil;
    UIImage *imageDeact = nil;
    UIImage *imageSel = nil;
    NSString *imageStr = nil;
    NSString *imageOnStr = nil;
    NSString *titleStr = nil;
    NSString *imageDeactStr = nil;
    NSString *imageSelStr = nil;
    CGSize defaultSize = CGSizeMake(52, 33);
    BOOL useDefaultSize = NO;
    switch (Type) {
        case SuperiorBarButtonSLMapType:
            imageStr = @"btnSatelite_mapa.png";
            imageOnStr = @"btnSatelite_mapa_press.png";
            break;
        case SuperiorBarButtonSLStoresType:
            imageStr = @"btn_listas";
            imageOnStr = @"btn_listas_press";
            break;
        case SuperiorBarButtonSLStoresNearMe:
            imageStr = @"btnTienda_barraSuperior.png";
            imageOnStr = @"btnTienda_barraSuperior_press.png";
            break;
        case SuperiorBarButtonSLDirections:
            imageStr = @"btnIndicaciones_barraInferior.png";
            imageOnStr = @"btnIndicaciones_barraInferior_press.png";
            break;
        case SuperiorBarButtonSLMap:
            imageStr = @"btnMapa_barraSuperior.png";
            imageOnStr = @"btnMapa_barraSuperior_press.png";
            break;
        case SuperiorBarButtonSLMyLocation:
            imageStr = @"btnLocalizacion_barraInferior.png";
            imageOnStr = @"btnLocalizacion_barraInferior_press";
            break;
        case SuperiorBarButtonSLConfiguration:
            imageStr = @"btnConfig_barraInferior.png";
            imageOnStr = @"btnConfig_barraInferior_press";
            break;
        default:
            return nil;
    }
    
    image = [UIImage imageNamed:imageStr];
    imageOn = [UIImage imageNamed:imageOnStr];
    imageDeact = [UIImage imageNamed:imageDeactStr];
    imageSel = [UIImage imageNamed:imageSelStr];
    
    CGRect frame;
    if (useDefaultSize) {
        frame = CGRectMake(0, 0, defaultSize.width, defaultSize.height);
    } else {
        frame = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    [button setTag:Type];
    [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [button setTitleColor:[UIColor colorWithRGBValue:0x5277b5] forState:UIControlStateNormal];
    [button setTitle:titleStr forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:imageOn forState:UIControlStateHighlighted];
    [button setBackgroundImage:imageDeact forState:UIControlStateDisabled];
    [button setBackgroundImage:imageSel forState:UIControlStateSelected];
    [button setFrame:frame];
    [button setBackgroundColor:[UIColor clearColor]];
    return button;
}

- (void)popNavigationViewControllerAnimated {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)popNavigationViewController {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)goHome {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)goToLoginScreen {
//    UIViewController *controller;
//    for (controller in [self.navigationController viewControllers])
//        if ([controller isKindOfClass:[TicketLoginViewController class]])
//            break;
//    [self.navigationController popToViewController:controller animated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}



- (UIAlertView *)showAlertViewWithTitle:(NSString*)title message:(NSString *)message buttonTitle:(NSString*)buttonTitle {
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:buttonTitle otherButtonTitles: nil];
    [alertview show];
    if (buttonTitle == nil) {
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:alertview selector:@selector(dismiss) userInfo:nil repeats:NO];
    }
    [[WebServicesManager defaultManager] removeObserver:(id)self];
    return alertview;
}

- (void)showLoadingView {
    UIView *keyView = [self keyView];
    UIView *loadingView = [keyView viewWithTag:LOADING_VIEW_TAG];
#if USE_SPINNER_ON_LOADING
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[loadingView viewWithTag:SPINNER_TAG];
#else
    UIImageView *imageView = (UIImageView*)[loadingView viewWithTag:LOADING_IMAGE_TAG];
#endif
    CGRect rect = keyView.frame;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        CGFloat temp = rect.size.width;
        rect.size.width = rect.size.height;
        rect.size.height = temp;
    } else {
        
    }
    loadingView.frame = rect;
    if (!loadingView) {
//        loadingView = [[UIView alloc] initWithFrame:keyView.frame];
//        [loadingView setTag:LOADING_VIEW_TAG];
//        UIView *view = [[UIView alloc] initWithFrame:keyView.frame];
//        [view setTag:BG_TAG];
//        [view setBackgroundColor:[UIColor blackColor]];
//        [view setAlpha:0.5];
//        [loadingView addSubview:view];
//        [view release];
//        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//        [spinner setCenter:CGPointMake(CGRectGetMidX(keyView.frame), CGRectGetMidY(keyView.frame))];
//        [loadingView addSubview:spinner];
//        [spinner setTag:SPINNER_TAG];
//        [spinner release];
//        [keyView addSubview:loadingView];
//        [loadingView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        loadingView = [[[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:nil options:nil] objectAtIndex:0];
        loadingView.frame = rect;
        [keyView addSubview:loadingView];
#if USE_SPINNER_ON_LOADING
        spinner = (UIActivityIndicatorView*)[loadingView viewWithTag:SPINNER_TAG];
#endif
        [loadingView setAlpha:0.0];
#if !USE_SPINNER_ON_LOADING
        NSMutableArray *imagesArray = [NSMutableArray array];
        for (int i = 1; i <= 24; i++) {
            NSString *imgStr = [NSString stringWithFormat:@"flor00%02d", i];
            UIImage *img = [UIImage imageNamed:imgStr];
            [imagesArray addObject:img];
        }
        imageView = (UIImageView*)[loadingView viewWithTag:LOADING_IMAGE_TAG];
        imageView.animationImages = imagesArray;
        imageView.animationDuration = 0.5;
        imageView.animationRepeatCount = 0;
#endif
    }
    [keyView bringSubviewToFront:loadingView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.30];
    [loadingView setAlpha:1.0];
    [UIView commitAnimations];
#if USE_SPINNER_ON_LOADING
    [spinner startAnimating];
#else
    [imageView startAnimating];
#endif
}

- (void)dismissLoadingView {
    UIView *keyView = [self keyView];
    UIView *loadingView = [keyView viewWithTag:LOADING_VIEW_TAG];
#if !USE_SPINNER_ON_LOADING
    UIImageView *imageView = (UIImageView*)[loadingView viewWithTag:LOADING_IMAGE_TAG];
    [imageView stopAnimating];
    [loadingView removeFromSuperview];
#else
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[loadingView viewWithTag:SPINNER_TAG];
    [spinner stopAnimating];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.30];
    [loadingView setAlpha:0.0];
    [UIView commitAnimations];
#endif
}

- (UIView *)keyView {
	UIWindow *w = [[UIApplication sharedApplication] keyWindow];
	if (w.subviews.count > 0) {
		return [w.subviews objectAtIndex:0];
	} else {
		return w;
	}
}

- (void)cleanUpLoadingView {
    
}

- (id)getCodeMessageFromJSonObject:(id)object {
    if ([object respondsToSelector:@selector(objectForKey:)]) {
        NSDictionary *dict = object;
        return [dict objectForKey:@"codeMessage"];
    } else if ([object respondsToSelector:@selector(objectAtIndex:)]) {
        NSArray *array = object;
        if ([array count] > 0) {
            NSDictionary *dict = [array objectAtIndex:0];
            return [dict objectForKey:@"codeMessage"];
        } else {
            return nil;
        }
    }
    return nil;
}


- (id)getValueFromJSonObject:(id)object forKey:(id)key{
    if ([object respondsToSelector:@selector(objectForKey:)]) {
        NSDictionary *dict = object;
        return [dict objectForKey:key];
    } else if ([object respondsToSelector:@selector(objectAtIndex:)]) {
        NSArray *array = object;
        if ([array count] > 0) {
            NSDictionary *dict = [array objectAtIndex:0];
            return [dict objectForKey:key];
        } else {
            return nil;
        }
    }
    return nil;
}

- (IBAction)cancelButtonPressed {
    [self dismissLoadingView];
    if ([self respondsToSelector:@selector(webServicesConnectionDidFinish:)])
        [[WebServicesManager defaultManager] removeObserver:(id<WebServicesObserver>)self];
    
}

- (UIImage*)getImageFromStoreId:(StoreId)storeId isBlue:(BOOL)isBlue {
//    NSArray *grayOrBlue = [NSArray arrayWithObjects:@"gris",@"azul",nil];
    NSArray *storesArray = [NSArray arrayWithObjects:@"aurrera",@"sams",@"superama",@"walmart",@"suburbia",@"vips",@"default",@"",@"porton",nil];
    NSString *sstringByTrimmingCharactersInSetage = nil;
    UIImage *image = nil;
    switch(storeId) {
            //case StoreIDElPorton:
            //sstringByTrimmingCharactersInSetage = [NSString stringWithFormat:@"logo_%@-%@.png", [storesArray objectAtIndex:6],[grayOrBlue objectAtIndex:(NSInteger)isBlue]];
            break;
        case StoreIDNoStore:
            return nil;
        default:
            sstringByTrimmingCharactersInSetage = [NSString stringWithFormat:@"indicador_%@.png", [storesArray objectAtIndex:(storeId - StoreIDBodegaAurrera)]];
            break;
    }
    image = [UIImage imageNamed:sstringByTrimmingCharactersInSetage];
    return image;
}


- (void)showDecisionAlertWithTitle:(NSString*)title message:(NSString*)message alertViewTag:(NSInteger)tag cancelButtonTitle:(NSString*)noButton okButtonTitle:(NSString *)okButton {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:noButton otherButtonTitles:okButton, nil];
    [alert setTag:tag];
    [alert show];
}

- (UIView *)getFirstResponder {
    return [self.view getFirstResponder];
}

- (WEPopoverContainerViewProperties *)getContainerViewProperties {
	
	WEPopoverContainerViewProperties *props = [WEPopoverContainerViewProperties alloc];
	NSString *bgImageName = @"popup_base.png";
    
	CGFloat bgMargin = 15.0;
	CGFloat bgCapSize = 0.0;
	CGFloat contentMargin = 4.0;
    CGSize ImageSize = CGSizeMake(30, 30);
	
	// These constants are determined by the popoverBg.png image file and are image dependent
	bgMargin = 10; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13 
	bgCapSize = ImageSize.width/2;
	props.leftBgMargin = bgMargin;
	props.rightBgMargin = bgMargin;
	props.topBgMargin = bgMargin;
	props.bottomBgMargin = bgMargin;
	props.leftBgCapSize = bgCapSize;
	props.topBgCapSize = bgCapSize;
	props.bgImageName = bgImageName;
	props.leftContentMargin = contentMargin;
	props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
	props.topContentMargin = contentMargin; 
	props.bottomContentMargin = contentMargin;
	props.arrowMargin = 4.0;
    props.upArrowImageName = @"popup_arriba.png";
    props.downArrowImageName = @"popup_abajo.png";
    props.leftArrowImageName = @"popup_izquierda.png";
    props.rightArrowImageName = @"popup_derecha.png";
	return props;	
}

- (void)logout {
    [self showLoadingView];
    [WebServicesManager connectWithType:WSConnectionTypeLogOut singleParam:nil jsonParam:nil originLocation:CLLocationCoordinate2DMake(0, 0) destLocation:CLLocationCoordinate2DMake(0, 0) withObserver:(id<WebServicesObserver>)self];
}


#pragma mark - ComboPickerView

- (ComboPickerView*)comboPickerView {
    if (!comboPickerView) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ComboPickerView" owner:nil options:nil];
        comboPickerView = [objects objectAtIndex:0];
        [comboPickerView setDelegate:(id<ComboPickerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>)self];
        CGRect rect = self.view.frame;
        CGRect pickerRect = self.comboPickerView.frame;
        pickerRect.origin.y = rect.size.height;
        comboPickerView.frame = pickerRect;
        [self.view addSubview:comboPickerView];
        
    }
    return comboPickerView;
}

- (NSInteger)numberOfComponentsInComboPickerView:(ComboPickerView *)comboPicker withActiveObject:(id)activeObject {
    return 0;
}

- (NSInteger)ComboPickerView:(ComboPickerView *)comboPicker numberOfRowsInComponent:(NSInteger)component activeObject:(id)activeObject {
    return 0;
}

- (NSString *)ComboPickerView:(ComboPickerView *)comboPicker titleForRow:(NSInteger)row forComponent:(NSInteger)component activeObject:(id)activeObject {
    return nil;
}

- (void)ComboPickerDidCancelSelection:(ComboPickerView *)comboPicker {
    
}

- (void)ComboPicker:(ComboPickerView *)comboPicker didSelectIndex:(NSInteger)index activeObject:(id)activeObject {
    
}

#pragma mark - AddToListView

//- (AddToListView*)addToListView {
//    if (!addToListView) {
//        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"AddToListView" owner:self options:nil];
//        addToListView = [[objects objectAtIndex:0] retain];
//        [addToListView setTag:ADD_TO_LIST_VIEW];
//    }
//    return addToListView;
//}


- (void)configureBackButtonWithSelector:(SEL)backFunction {
    UIButton *button = [self getButtonFromType:SuperiorBarButtonBack];
    [button addTarget:self action:backFunction forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* br = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:br animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {    
    TicketListAVType type = [alertView tag];
    switch (type) {
        case TicketListAVTypeUserNotInSession:
        {
            [self goToLoginScreen];
            break;
        }
        default:
            break;
    } 
}

#pragma mark - WEPopoverControllerDelegate 
- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController {
    self.popoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController {
    return YES;
}


-(NSString *)getWeightValueForIndex:(NSInteger)index withStep:(CGFloat)step{
#if WEIGHT_QTY_AS_KG
    NSString *string = [NSString stringWithFormat:@"%.02f", (index+1)*step];
#else
    NSString *string = [NSString stringWithFormat:@"%g", (index+1)*step];
#endif
    return string;
}

- (void)activateKeyboardObserver{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardDidShow:) 
													 name:UIKeyboardDidShowNotification 
												   object:nil];		
	} else {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardWillShow:) 
													 name:UIKeyboardWillShowNotification 
												   object:nil];
	}
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UITextFieldTextDidBeginEditingNotification 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(textFieldDidBeginEditing:)
                                                 name:UITextFieldTextDidBeginEditingNotification 
                                               object:nil];

}

- (void)removeKeyboardObserver {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:UIKeyboardDidShowNotification 
                                                      object:nil];      
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:UIKeyboardWillShowNotification 
                                                      object:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UITextFieldTextDidBeginEditingNotification 
                                                  object:nil];
}

- (void)keyboardWillShow:(NSNotification *)note {  
    // create custom button
    [self updateKeyboardButtonFor:(UITextField*)[self.view getFirstResponder]];
}

- (void)keyboardDidShow:(NSNotification *)note {  
    // create custom button
    [self updateKeyboardButtonFor:(UITextField*)[self.view getFirstResponder]];
}

- (void)textFieldDidBeginEditing:(NSNotification *)note {
    if ([(id)note isKindOfClass:[NSNotification class]]) {
        [self updateKeyboardButtonFor:[note object]];
    } else { 
        [self updateKeyboardButtonFor:(UITextField*)((id)note)];
    }
}


- (void)updateKeyboardButtonFor:(UITextField *)textField {
    
    // Remove any previous button
    [self.numberPadDoneButton removeFromSuperview];
    self.numberPadDoneButton = nil;

    
    // Does the text field use a number pad?
    if (textField.keyboardType != UIKeyboardTypeNumberPad) {
        return;
    }
        
    
    // If there's no keyboard yet, don't do anything
    if ([[[UIApplication sharedApplication] windows] count] < 2)
        return;
    UIWindow *keyboardWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    
    // Create new custom button
    self.numberPadDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    numberPadDoneButton.frame = CGRectMake(0, 163, 106, 53);
    numberPadDoneButton.adjustsImageWhenHighlighted = NO;
    [numberPadDoneButton setImage:[UIImage imageNamed:@"DoneUp.png"] forState:UIControlStateNormal];
    [numberPadDoneButton setImage:[UIImage imageNamed:@"DoneDown.png"] forState:UIControlStateHighlighted];
    [numberPadDoneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
    
    // Locate keyboard view and add button
    NSString *keyboardPrefix = [[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2 ? @"<UIPeripheralHost" : @"<UIKeyboard";
    for (UIView *subView in keyboardWindow.subviews) {
        if ([[subView description] hasPrefix:keyboardPrefix]) {
            [subView addSubview:numberPadDoneButton];
            break;
        }
    }
}

- (NSError *)googleAnalyticsTrackEvent:(NSString*)event action:(NSString*)action label:(NSString*)label value:(NSInteger)value{
#if USE_GOOGLE_ANALYTICS
    NSError *error;
    if (![[GANTracker sharedTracker] trackEvent:event
                                         action:action
                                          label:label
                                          value:value   
                                      withError:&error]) {
        NSLog(@"There was an error during tracking: %@", error);
        return error;
    }
#endif
    return nil;
    
}


- (NSString *)formattedStringFromDate:(NSDate*)date usingFormat:(NSString *)dateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:[NSLocale currentLocale]];
    NSString *ret = [formatter stringFromDate:date];
    NSString *string = [NSString stringWithFormat:@"%@",ret];
    return string;
}

- (NSDate*)dateFromString:(NSString*)dateAsString withFormat:(NSString*)format {
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:format];
    return [df dateFromString:dateAsString];
}



- (BOOL) shouldResizeAccordingToResolution{
    return YES;
}

//Update a list of devices:
//In future will be updated with iPad 4.
+  (Device)deviceModelName {
    /*
     @"i386"      on the simulator
     @"x86_64"    on the simulator
     @"iPod1,1"   on iPod Touch
     @"iPod2,1"   on iPod Touch Second Generation
     @"iPod3,1"   on iPod Touch Third Generation
     @"iPod4,1"   on iPod Touch Fourth Generation
     @"iPod5,1"   on iPod Touch Fourth Generation
     @"iPhone1,1" on iPhone
     @"iPhone1,2" on iPhone 3G
     @"iPhone2,1" on iPhone 3GS
     @"iPad1,1"   on iPad
     @"iPad2,1"   on iPad 2
     @"iPad2,5"   on iPad mini 1
     @"iPad3,1"   on iPad 3
     @"iPhone3,1" on iPhone 4
     @"iPhone4,1" on iPhone 4S
     @"iPhone5,1" on iPhone 5
     */
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *modelName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    Device device = DeviceUnknown;
    if([modelName isEqualToString:@"i386"] || [modelName isEqualToString:@"x86_64"]) {
        modelName = @"iPhone Simulator";
        device = DeviceSimulator;
    }
    else if([modelName isEqualToString:@"iPhone1,1"]) {
        modelName = @"iPhone";
        device = DeviceiPhone1;
    }
    else if([modelName isEqualToString:@"iPhone1,2"]) {
        modelName = @"iPhone 3G";
        device = DeviceiPhone3G;
    }
    else if([modelName isEqualToString:@"iPhone2,1"]) {
        modelName = @"iPhone 3GS";
        device = DeviceiPhone3GS;
    }
    else if([modelName isEqualToString:@"iPhone3,1"]) {
        modelName = @"iPhone 4";
        device = DeviceiPhone4;
    }
    else if([modelName isEqualToString:@"iPhone4,1"]) {
        modelName = @"iPhone 4S";
        device = DeviceiPhone4S;
    }
    else if([modelName isEqualToString:@"iPhone5,1"]) {
        modelName = @"iPhone 5";
        device = DeviceiPhone5;
    }
    else if([modelName isEqualToString:@"iPod1,1"]) {
        modelName = @"iPod 1st Gen";
        device = DeviceiPod1stGen;
    }
    else if([modelName isEqualToString:@"iPod2,1"]) {
        modelName = @"iPod 2nd Gen";
        device = DeviceiPod2ndGen;
    }
    else if([modelName isEqualToString:@"iPod3,1"]) {
        modelName = @"iPod 3rd Gen";
        device = DeviceiPod3rdGen;
    }
    else if([modelName isEqualToString:@"iPod4,1"]) {
        modelName = @"iPod 4rd Gen";
        device = DeviceiPod4thGen;
    }
    else if([modelName isEqualToString:@"iPod5,1"]) {
        modelName = @"iPod 5rd Gen";
        device = DeviceiPod5thGen;
    }
    else if([modelName isEqualToString:@"iPad1,1"]) {
        modelName = @"iPad";
        device = DeviceiPad1;
    }
    else if([modelName isEqualToString:@"iPad2,1"]) {
        modelName = @"iPad 2(WiFi)";
        device = DeviceiPad2Wifi;
    }
    else if([modelName isEqualToString:@"iPad2,2"]) {
        modelName = @"iPad 2(GSM)";
        device = DeviceiPad2GSM;
    }
    else if([modelName isEqualToString:@"iPad2,3"]) {
        modelName = @"iPad 2(CDMA)";
        device = DeviceiPad2CDMA;
    }
    else if([modelName isEqualToString:@"iPad2,4"]) {
        modelName = @"iPad 2(WiFi + New Chip)";
        device = DeviceiPad2New;
    }
    else if([modelName isEqualToString:@"iPad2,5"]) {
        modelName = @"iPad mini (WiFi)";
        device = DeviceiPadMiniWifi;
    }
    else if([modelName isEqualToString:@"iPad2,6"]) {
        modelName = @"iPad mini (GSM)";
        device = DeviceiPadMiniGSM;
    }
    else if([modelName isEqualToString:@"iPad3,1"]) {
        modelName = @"iPad 3(WiFi)";
        device = DeviceiPad3Wifi;
    }
    else if([modelName isEqualToString:@"iPad3,2"]) {
        modelName = @"iPad 3(GSM)";
        device = DeviceiPad3GSM;
    }
    else if([modelName isEqualToString:@"iPad3,3"]) {
        modelName = @"iPad 3(CDMA)";
        device = DeviceiPad3CDMA;
    }
    return device;
}

#if USE_GOMEZ_TAGGING
- (void)startGomezInterval:(NSString*)eventName {
    NSInteger result = [CompuwareUEM startInterval:eventName];
    NSLog(@"Starting Interval: %@, result: %d, on class: %@", eventName, result, NSStringFromClass([self class]));
}

- (void)nameGomezEvent:(NSString*)eventName {
//    NSInteger result = [CompuwareUEM nameEvent:eventName];
//    NSLog(@"Naming event: %@, result: %d, on class: %@", eventName, result, NSStringFromClass([self class]));
}

- (void)endGomezInterval:(NSString*)eventName {
    NSInteger result = [CompuwareUEM endInterval:eventName];
    NSLog(@"Ending Interval: %@, result: %d, on class: %@", eventName, result, NSStringFromClass([self class]));
}

- (void)customGomezValue:(NSString*)eventName value:(NSInteger)value {
    NSInteger result = [CompuwareUEM customValue:eventName eventValue:value];
    NSLog(@"Setting Custom Value on Event: %@, value: %d, result: %d, on class: %@", eventName, value, result, NSStringFromClass([self class]));
}
#endif

@end
