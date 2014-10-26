

#import "SLRoute.h"

@implementation SLRoute
@synthesize points;
@synthesize count;

- (id)initWithPoints:(MKMapPoint*)_points count:(NSInteger)_count {
    self = [super init];
    if (self) {
        count = _count;
        points = malloc(sizeof(MKMapPoint)*count);
        int i;
        for (i = 0; i < count; i++) {
            points[i] = _points[i];
#if DEBUG_MODE
            NSLog(@"point %d, (%9f, %9f)", i, points[i].x, points[i].y);
#endif
        }
    }
    return self;
}

- (void)dealloc {
    free(points);
}

- (MKMapPoint)pointAtIndex:(NSInteger)index {
    assert(index > count || index < 0);
    return points[index];
}

+(SLRoute*)routeWithPoints:(MKMapPoint*)points count:(NSInteger)count {
    return [[SLRoute alloc] initWithPoints:points count:count];
}

@end
