

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface UserAnnotation : NSObject <MKAnnotation>
{
    UIImageView *leftCalloutView;
    CLLocationCoordinate2D coordinate;
    NSString *currentAddress;
    
}

@property (nonatomic,readonly) UIImageView *leftCalloutView;

@end
