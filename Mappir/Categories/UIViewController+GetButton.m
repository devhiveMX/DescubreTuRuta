

#import "UIViewController+GetButton.h"
#import "UIColor+RGB.h"
#import "WSConnection.h"
#import "WebServicesManager.h"
#import "UIView+getFirstResponder.h"
#import "WEPopoverContainerView.h"
#import "NSObject+IsNullOrNil.h"
#import "NSString+IsNumber.h"

@implementation UIViewController (GetButton)


- (UIButton*)getButtonFromType:(SuperiorBarButtonType)Type {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = nil;
    UIImage *imageOn = nil;
    UIImage *imageDeact = nil;
    NSString *imageStr = nil;
    NSString *imageOnStr = nil;
    NSString *titleStr = nil;
    NSString *imageDeactStr = nil;
    
    switch (Type) {
        
        case SuperiorBarButtonHomeSquare:
            imageStr = @"btnHomeCuadro_barraSuperior.png";
            imageOnStr = @"btnHomeCuadro_barraSuperior_press.png";
            break;
        case SuperiorBarButtonSLStoresType:
            imageStr = @"btnListas_barraSuperior.png";
            imageOnStr = @"btnListas_barraSuperior_press.png";
            break;
        case SuperiorBarButtonSLStoresNearMe:
            imageStr = @"btnTienda_barraSuperior.png";
            imageOnStr = @"btnTienda_barraSuperior_press.png";
            break;
        case SuperiorBarButtonRoute:
            imageStr = @"btnRuta_barraSuperior.png";
            imageOnStr = @"btnRuta_barraSuperior_press.png";
            break;
        case SuperiorBarButtonSLDirections:
            imageStr = @"btnIndicaciones_barraInferior.png";
            imageOnStr = @"btnIndicaciones_barraInferior_press.png";
            break;
        case SuperiorBarButtonSLMap:
            imageStr = @"btnMapa_barraSuperior.png";
            imageOnStr = @"btnMapa_barraSuperior_press.png";
            break;
        default:
            return nil;
    }
    
    image = [UIImage imageNamed:imageStr];
    imageOn = [UIImage imageNamed:imageOnStr];
    imageDeact = [UIImage imageNamed:imageDeactStr];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [button setTag:Type];
    [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [button setTitleColor:[UIColor colorWithRGBValue:0x5277b5] forState:UIControlStateNormal];
    [button setTitle:titleStr forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:imageOn forState:UIControlStateHighlighted];
    [button setBackgroundImage:imageDeact forState:UIControlStateDisabled];
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


- (void)showAlertViewWithTitle:(NSString*)title message:(NSString *)message buttonTitle:(NSString*)buttonTitle {
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:buttonTitle otherButtonTitles: nil];
    [alertview show];
    [[WebServicesManager defaultManager] removeObserver:(id)self];
}

- (void)showLoadingView {
    UIView *keyView = [self keyView];
    UIView *loadingView = [keyView viewWithTag:LOADING_VIEW_TAG];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[loadingView viewWithTag:SPINNER_TAG];
    if (!loadingView) {
        loadingView = [[UIView alloc] initWithFrame:keyView.frame];
        [loadingView setTag:LOADING_VIEW_TAG];
        UIView *view = [[UIView alloc] initWithFrame:keyView.frame];
        [view setTag:BG_TAG];
        [view setBackgroundColor:[UIColor blackColor]];
        [view setAlpha:0.5];
        [loadingView addSubview:view];
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [spinner setCenter:CGPointMake(CGRectGetMidX(keyView.frame), CGRectGetMidY(keyView.frame))];
        [loadingView addSubview:spinner];
        [spinner setTag:SPINNER_TAG];
        [keyView addSubview:loadingView];
        [loadingView setAlpha:0.0];
    }
    [keyView bringSubviewToFront:loadingView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.30];
    [loadingView setAlpha:1.0];
    [UIView commitAnimations];
    [spinner startAnimating];
}

- (void)dismissLoadingView {
    UIView *keyView = [self keyView];
    UIView *loadingView = [keyView viewWithTag:LOADING_VIEW_TAG];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[loadingView viewWithTag:SPINNER_TAG];
    [spinner stopAnimating];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.30];
    [loadingView setAlpha:0.0];
    [UIView commitAnimations];
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

- (BOOL)isMailValid:(NSString*)mailString {
    //NSError *error = nil;
    if (mailString == nil) return NO;
    NSString *mailRegEx = REGEX_EMAIL;    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mailRegEx];
    BOOL matches = ([emailTest evaluateWithObject:mailString]);
    return matches;
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
    NSArray *grayOrBlue = [NSArray arrayWithObjects:@"gris",@"azul",nil];
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
            sstringByTrimmingCharactersInSetage = [NSString stringWithFormat:@"logo_%@-%@.png", [storesArray objectAtIndex:(storeId - StoreIDBodegaAurrera)],[grayOrBlue objectAtIndex:(NSInteger)isBlue]];
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


@end
