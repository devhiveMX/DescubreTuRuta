

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface DirectionAnnotation : NSObject <MKAnnotation> {
	// Callout properties
    
    NSDictionary *dictionary;
	CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
    NSInteger stepNumber;
}

@property (nonatomic, readonly, retain) NSDictionary *dictionary;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSInteger stepNumber;

- (id) initWithDictionary:(NSDictionary *)dict;
- (void)updateInfoDict:(NSDictionary*)dict;

@end
