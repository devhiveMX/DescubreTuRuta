//
//  ARDetailView.m
//  Superama1.5
//
//  Created by WALMEX3.0 _1 WALMART on 30/08/12.
//  Copyright (c) 2012 WALMART. All rights reserved.
//

#import "ARDetailView.h"
#import <QuartzCore/QuartzCore.h>
@implementation ARDetailView
@synthesize button1;
@synthesize button2;
@synthesize detailLabel;
@synthesize imageView;
@synthesize titleLabel;
@synthesize distanceLabel;
@synthesize hoursLabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 5;
    
}

- (void)dealloc {
    self.titleLabel = nil;
    self.imageView = nil;
    self.detailLabel = nil;
    self.button1 = nil;
    self.button2 = nil;
    self.hoursLabel = nil;
    self.distanceLabel = nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)buttonPressed:(id)sender {
    //    [self animateHighlightOnTouch];
    [self.superview bringSubviewToFront:self];
    NSNotification* notification = [NSNotification notificationWithName:@"detailViewButtonPressed"
                                                                 object:sender
                                                               userInfo:nil];
    //    [NSDictionary dictionaryWithObjectsAndKeys:[[connection.responseData copy] autorelease],@"data",[NSNumber numberWithInt:connection.type], @"type", nil]
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
}

@end
