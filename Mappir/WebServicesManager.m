

#import "WebServicesManager.h"
#import "JSONKit.h"


static WebServicesManager *_instance;

inline static NSString* keyForURL(NSURL* url) {
	return [NSString stringWithFormat:@"WebServices-%u", [[url description] hash]];
}

#define kWSNotificationFinished(s) [@"kWebServicesNotificationFinished-" stringByAppendingString:keyForURL(s)]
#define kWSNotificationFailed(s) [@"kWebServicesNotificationFailed-" stringByAppendingString:keyForURL(s)]

@implementation WebServicesManager
@synthesize currentConnections;


+(WebServicesManager*)defaultManager {
    if (!_instance) {
        _instance = [[[self class] alloc] init];
    }
    return _instance;
}

+(void)connectWithType:(WSConnectionType)connectionType singleParam:(NSString*)param jsonParam:(NSString*)jsonParam originLocation:(CLLocationCoordinate2D)origin destLocation:(CLLocationCoordinate2D)destination withObserver:(id<WebServicesObserver>)observer {
    WSConnection *connection = nil;
    switch(connectionType)
    {
        case WSConnectionTypeGoogleInverseGeocoding:
            connection = [WSConnection connectionForInverseGeocodingWithOrigin:origin delegate:[self defaultManager]];
            break;
        default:
            connection = [WSConnection connectionWithType:connectionType stringParam:param jsonParam:jsonParam delegate:[WebServicesManager defaultManager]];
            break;
    }
    
    [[self defaultManager] loadConnection:connection withObserver:observer];
}

+(void)searchWithCriteria:(NSString*)criteria and4Square:(BOOL)fourSquareEnabled andGooglePlaces:(BOOL)places observer:(id<WebServicesObserver>)observer{
    NSString *finalCriteria = [criteria stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    if (fourSquareEnabled) {
        finalCriteria = [finalCriteria stringByAppendingString:@"&4sq"];
    }
    if (places) {
        finalCriteria = [finalCriteria stringByAppendingString:@"&gplaces"];
    }
    [WebServicesManager connectWithType:WSConnectionTypeLocationSearch singleParam:finalCriteria jsonParam:nil originLocation:CLLocationCoordinate2DZero destLocation:CLLocationCoordinate2DZero withObserver:observer];
}

- (void)loadConnection:(WSConnection*)connection withObserver: (id<WebServicesObserver>)observer {
    if([observer respondsToSelector:@selector(webServicesConnectionDidFinish:)]) {
		[[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(webServicesConnectionDidFinish:) name:kWSNotificationFinished(connection.url) object:self];
	}
	
	if([observer respondsToSelector:@selector(webServicesConnectionDidFail:)]) {
		[[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(webServicesConnectionDidFail:) name:kWSNotificationFailed(connection.url) object:self];
	}
    
    [self.currentConnections setObject:connection forKey:connection.url];
    [connection performSelector:@selector(connect) withObject:nil afterDelay:0.01];
}
- (void)wsConnectionDidFinishLoading:(WSConnection *)connection {
    [self.currentConnections removeObjectForKey:connection.url];
    self.currentConnections = [currentConnections copy];
    
    
    id resultDictionary = [connection.responseData objectFromJSONData];
    
    NSDictionary *userInfo = nil;
    
    if ([resultDictionary respondsToSelector:@selector(objectForKey:)]) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:resultDictionary,@"resultDictionary",[NSNumber numberWithInt:connection.type], @"type", nil];
    } else {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:resultDictionary,@"resultArray",[NSNumber numberWithInt:connection.type], @"type", nil];
    }
    NSNotification* notification = [NSNotification notificationWithName:kWSNotificationFinished(connection.url)
                                                                 object:self
                                                               userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
    
}

- (void)wsConnection:(WSConnection *)connection didFailWithError:(NSError *)error {
    [self.currentConnections removeObjectForKey:connection.url];
    self.currentConnections = [currentConnections copy];

    NSNotification* notification = [NSNotification notificationWithName:kWSNotificationFailed(connection.url)
                                                                 object:self
                                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error,@"error",[NSNumber numberWithInt:connection.type], @"type",nil]];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
}

- (void)removeObserver:(id<WebServicesObserver>)observer {
	[[NSNotificationCenter defaultCenter] removeObserver:observer name:nil object:self];
}


@end
