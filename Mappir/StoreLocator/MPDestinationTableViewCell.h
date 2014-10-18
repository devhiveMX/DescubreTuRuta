//
//  MPDestinationTableViewCell.h
//  Mappir
//
//  Created by Leonardo Cid on 12/10/14.
//  Copyright (c) 2014 Devhive. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TypeOrigin,
    TypeMiddle,
    TypeDestination,
    TypeDestinationFinal
} DestinationCellType;

@interface MPDestinationTableViewCell : UITableViewCell

- (void)configure:(DestinationCellType)type;

@property (nonatomic, strong, readonly) IBOutlet UILabel *alphabeticLabel;
@property (nonatomic, strong, readonly) IBOutlet UITextField *destinationInfoTextField;
@property (nonatomic, strong, readonly) IBOutlet UIButton *swapDestinationButton;
@property (nonatomic, strong, readonly) IBOutlet UIButton *deleteButton;
@property (nonatomic) BOOL configured;
@end
