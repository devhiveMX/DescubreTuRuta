//
//  MPDestinationTableViewCell.m
//  Mappir
//
//  Created by Leonardo Cid on 12/10/14.
//  Copyright (c) 2014 Devhive. All rights reserved.
//

#import "MPDestinationTableViewCell.h"
#import "UIColor+RGB.h"

@interface MPDestinationTableViewCell ()
@property (nonatomic, strong) IBOutlet UILabel *alphabeticLabel;
@property (nonatomic, strong) IBOutlet UITextField *destinationInfoTextField;
@property (nonatomic, strong) IBOutlet UIButton *swapDestinationButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@end

@implementation MPDestinationTableViewCell
@synthesize alphabeticLabel, destinationInfoTextField, swapDestinationButton, deleteButton;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    [self configure:TypeOrigin];
}

- (void)configure:(DestinationCellType)type {
    switch(type) {
        case TypeDestination:
        {
            [self.alphabeticLabel.layer setBorderWidth:2];
            [self.alphabeticLabel.layer setCornerRadius:12.5];
            [self.alphabeticLabel.layer setBorderColor: [[UIColor whiteColor] CGColor]];
            [self.alphabeticLabel setTextColor:[UIColor whiteColor]];
            [self.alphabeticLabel setBackgroundColor:[UIColor colorWithRGBValue:0x10752f]];
            
            [self.swapDestinationButton.layer setCornerRadius:15];
            [self.swapDestinationButton setTitle:@"+" forState:UIControlStateNormal];
            [self.swapDestinationButton setHidden:NO];
            
            [self.deleteButton.layer setHidden:YES];
            [self.deleteButton.layer setCornerRadius:15];
            
            [self.destinationInfoTextField setPlaceholder:@"Hasta..."];
        }
            break;
        case TypeMiddle:
        {
            [self.alphabeticLabel.layer setCornerRadius:12.5];
            [self.alphabeticLabel.layer setBorderWidth:1];
            [self.alphabeticLabel setBackgroundColor:[UIColor clearColor]];
            [self.alphabeticLabel.layer setBorderColor: [[UIColor colorWithRGBValue:0x10752f] CGColor]];
            [self.alphabeticLabel setTextColor:[UIColor colorWithRGBValue:0x10752f]];
            
            [self.swapDestinationButton.layer setCornerRadius:5];
            [self.swapDestinationButton setTitle:@"" forState:UIControlStateNormal];
            [self.swapDestinationButton setHidden:NO];
            
            [self.deleteButton.layer setHidden:NO];
            [self.deleteButton.layer setCornerRadius:15];
            
            [self.destinationInfoTextField setPlaceholder:@"A..."];
        }
            break;
        case TypeOrigin:
        {
            [self.alphabeticLabel.layer setBorderWidth:2];
            [self.alphabeticLabel.layer setCornerRadius:12.5];
            [self.alphabeticLabel.layer setBorderColor: [[UIColor colorWithRGBValue:0x10752f] CGColor]];
            [self.alphabeticLabel setTextColor:[UIColor colorWithRGBValue:0x10752f]];
            [self.alphabeticLabel setBackgroundColor:[UIColor whiteColor]];
            
            [self.swapDestinationButton.layer setCornerRadius:5];
            [self.swapDestinationButton setTitle:@"" forState:UIControlStateNormal];
            [self.swapDestinationButton setHidden:NO];
            
            [self.deleteButton.layer setHidden:YES];
            
            [self.destinationInfoTextField setPlaceholder:@"De..."];
        }
            break;
        case TypeDestinationFinal:
        {
            [self.alphabeticLabel setTextColor:[UIColor whiteColor]];
            [self.alphabeticLabel setBackgroundColor:[UIColor colorWithRGBValue:0x10752f]];
            
            [self.swapDestinationButton setHidden:YES];
            [self.swapDestinationButton setTitle:@"" forState:UIControlStateNormal];
            
            [self.deleteButton.layer setHidden:YES];
            
            [self.deleteButton setHidden:YES];
        }
            break;
    }
    [self.alphabeticLabel setClipsToBounds:YES];
    [self.swapDestinationButton setClipsToBounds:YES];
    [self.deleteButton setClipsToBounds:YES];
}

@end
