//
//  DirectionAnnotationView.m
//  Superama1.5
//
//  Created by Walmart1 on 01/03/13.
//  Copyright (c) 2013 WALMART. All rights reserved.
//

#import "DirectionAnnotationView.h"
#import "DirectionAnnotation.h"
#import "UIColor+RGB.h"

@implementation DirectionAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, 30, 30);
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context,rect);
    if (self.image) {
        UIImage * backgroundImage = self.image;
        CGRect annotationRectangle = CGRectMake(0.0f, 0.0f, backgroundImage.size.width, backgroundImage.size.height);
        [backgroundImage drawInRect: annotationRectangle];
    }
    
    CGRect borderRect = CGRectMake(1.0, 1.0, 28.0, 28.0);
    CGContextSetRGBStrokeColor(context, 0.1, 0.7, 0.2, 1.0);
    CGContextSetRGBFillColor(context, 1.0,1.0,1.0, 1.0);
    CGContextSetLineWidth(context, 1.0);
    CGContextFillEllipseInRect (context, borderRect);
    CGContextStrokeEllipseInRect(context, borderRect);
    CGContextFillPath(context);
    
    DirectionAnnotation *annotation = self.annotation;
    [[UIColor colorWithRGBValue:0x067e1C] set];
    UIFont * font = [UIFont boldSystemFontOfSize: 10.0];
    NSString * text = [NSString stringWithFormat: @"%d", annotation.stepNumber];
    CGSize size = [text sizeWithFont:font];
    CGPoint point = CGPointMake((rect.size.width - size.width) /2, (rect.size.height - size.height) / 2);
    
    [text drawAtPoint: point withFont: font];
}


@end
