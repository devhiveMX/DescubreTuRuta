

#import "UserAnnotation.h"

@implementation UserAnnotation 
@synthesize leftCalloutView;
@synthesize coordinate;


- (id)initWithCurrentAddress:(NSString*)address coordinate:(CLLocationCoordinate2D)location {
    self = [super init];
    if (self) {
        currentAddress = address;
        [self setCoordinate: location];
    }
    return self;
}

- (void)dealloc {
}

- (NSString*)title {
    return @"Ubicación actual";
}

- (NSString*)subtitle {
    return currentAddress;
}
@end
