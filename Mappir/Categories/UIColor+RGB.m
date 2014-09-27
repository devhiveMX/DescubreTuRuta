//
//  UIColor+RGB.m
//  WalmartApp
//
//  Created by WALMEX3.0 _1 WALMART on 28/07/11.
//  Copyright 2011 Walmart Stores Inc. All rights reserved.
//

#import "UIColor+RGB.h"


@implementation UIColor (RGB)

+(UIColor*)colorWithRGBValue:(NSInteger)rgbValue {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

@end
