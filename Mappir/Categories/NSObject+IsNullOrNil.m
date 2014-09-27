//
//  NSObject+IsNullOrNil.m
//  WalmartApp
//
//  Created by WALMEX3.0_1_WALMART on 28/09/11.
//  Copyright 2011 Walmart Stores Inc. All rights reserved.
//

#import "NSObject+IsNullOrNil.h"


@implementation NSObject (NSObject_IsNullOrNil)


- (BOOL)isNullOrNil {
    return [self isNil] || [self isNull];  
}
- (BOOL)isNil {
    return self == nil;
}

- (BOOL)isNull {
    return self == [NSNull null];
}
@end
