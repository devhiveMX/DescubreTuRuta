

#import "DirectionAnnotation.h"

@interface DirectionAnnotation()
    @property (nonatomic, retain) NSDictionary *dictionary;
    @property (nonatomic, copy) NSString *title;
    @property (nonatomic, copy) NSString *subtitle;
    @property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

@implementation DirectionAnnotation
@synthesize dictionary;
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize stepNumber;


- (id) initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if ( self ) {
        [self updateInfoDict:dict];
    }
    
    return self;
}

- (void)updateInfoDict:(NSDictionary*)dict {
    self.dictionary = dict;
    NSDictionary *loc = [self.dictionary objectForKey:@"start_location"];
    CLLocationDegrees lat = [[loc objectForKey:@"lat"] doubleValue];
    CLLocationDegrees lng = [[loc objectForKey:@"lng"] doubleValue];
    self.coordinate = CLLocationCoordinate2DMake(lat, lng);
    self.title = @"Direcciones";
    self.subtitle = [self.dictionary objectForKey:@"html_instructions"];
}

- (void) dealloc {
    self.dictionary = nil;
    self.title = nil;
    self.subtitle = nil;
}

#pragma mark -
#pragma mark Callout methods

- (NSString *) title {
	return title;
}

- (NSString *) subtitle {
    return subtitle;
}

- (CLLocationCoordinate2D) coordinate {
    return coordinate;
}

- (void)setStepNumber:(NSInteger)_stepNumber {
    stepNumber = _stepNumber;
    self.title = [NSString stringWithFormat:@"Paso %d", (int)stepNumber];
}

@end
