

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>

@interface SLRoute : NSObject{
    MKMapPoint *points;
    NSInteger count;
}

@property (nonatomic, readonly) MKMapPoint *points;
@property (nonatomic, readonly) NSInteger count;

- (id)initWithPoints:(MKMapPoint*)_points count:(NSInteger)_count;
+(SLRoute*)routeWithPoints:(MKMapPoint*)points count:(NSInteger)count;


@end
