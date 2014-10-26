

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
