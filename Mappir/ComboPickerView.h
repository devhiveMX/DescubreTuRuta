//
//  ComboPickerView.h
//  WalmartArgentina
//
//  Created by WALMEX3.0 _1 WALMART on 26/01/12.
//  Copyright (c) 2012 WALMART. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomToolbar.h"
#import "SlideView.h"
@class ComboPickerView;
@protocol ComboPickerViewDelegate <NSObject>
- (void)ComboPicker:(ComboPickerView*)comboPicker didSelectIndex:(NSInteger)index activeObject:(id)activeObject;
- (void)ComboPickerDidCancelSelection:(ComboPickerView*)comboPicker;
- (NSString*)ComboPickerView:(ComboPickerView *)comboPicker titleForRow:(NSInteger)row forComponent:(NSInteger)component activeObject:(id)activeObject;
- (NSInteger)ComboPickerView:(ComboPickerView *)comboPicker numberOfRowsInComponent:(NSInteger)component activeObject:(id)activeObject;
- (NSInteger)numberOfComponentsInComboPickerView:(ComboPickerView *)comboPicker withActiveObject:(id)activeObject;
@optional
- (void)ComboPickerWillShow:(ComboPickerView*)comboPicker withActiveObject:(id)object;
- (void)ComboPickerWillDismiss:(ComboPickerView*)comboPicker;
- (NSInteger)ComboPickerView:(ComboPickerView*)comboPicker initialSelectedRowforComponent:(NSInteger)component;
@end

@interface ComboPickerView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>{
    BOOL isShowing;
}
@property (nonatomic, retain) IBOutlet UIPickerView *picker;
@property (nonatomic, retain) IBOutlet CustomToolbar *toolbar;
@property (nonatomic, assign) IBOutlet id<ComboPickerViewDelegate> delegate;
@property (nonatomic, assign) id activeObject;
@property (nonatomic, assign) BOOL isShowing;

- (void)dismiss;
- (void)showWithActiveObject:(id)object;
- (IBAction)buttonPressed:(id)sender;
@end
