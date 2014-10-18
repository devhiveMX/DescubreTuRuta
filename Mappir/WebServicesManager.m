//
//  WebServicesManager.m
//  WalmartApp
//
//  Created by WALMEX3.0_1_WALMART on 15/09/11.
//  Copyright 2011 Walmart Stores Inc. All rights reserved.
//

#import "WebServicesManager.h"


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
//        //Connetions made by GET with param in the URL
//        case WSConnectionTypeAddItemToList:      
//        case WSConnectionTypeGetListByID:
//        case WSConnectionTypeDeleteTicketList:
//        case WSConnectionTypeSendTicketByEmail:
//        //Connections made by GET without parameters
//        case WSConnectionTypeCreatelist:
//        case WSConnectionTypeSaveList:
//        case WSConnectionTypeGetListByUser:
//        case WSConnectionTypeGetPurchaseHistoryByUser:    
//        case WSConnectionTypeGetShoppingCart:
//        case WSConnectionTypeUpdateTicketList:
//        case WSConnectionTypeGetCategoriesList:
//        case WSConnectionTypeLogOut:    
//        case WSConnectionTypePaymentTypeCatalog:
//        case WSConnectionTypeDeliveryTypeCatalog:
//        //Connections made by POST with jsonParameter
//        case WSConnectionTypeSendOrderByEmail:
//        case WSConnectionTypeCreateUser:
//        case WSConnectionTypeLogin:            
//        case WSConnectionTypeDeleteItem:
//        case WSConnectionTypeUpdateItemByItem:
//        case WSConnectionTypeGetItemByUPC:
//        case WSConnectiontypeSLByBusiness:
//            
//            break;
        //Connections made by GET with the Google API
        case WSConnectionTypeGoogleInverseGeocoding:
            connection = [WSConnection connectionForInverseGeocodingWithOrigin:origin delegate:[self defaultManager]];
            break;
//        case WSConnectionTypeGoogleTraceroute:
//            connection = [WSConnection connectionForTraceRouteFromOrigin:origin toDestination:destination delegate:[self defaultManager]];
//            break;
//        case WSConnectionTypeGoogleTracerouteOnFoot:
//            connection = [WSConnection connectionForTraceRouteOnFootFromOrigin:origin toDestination:destination delegate:[self defaultManager]];
//            break;
        default:
            connection = [WSConnection connectionWithType:connectionType stringParam:param jsonParam:jsonParam delegate:[WebServicesManager defaultManager]];
            break;
    }
    
    [[self defaultManager] loadConnection:connection withObserver:observer];
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
    
    NSNotification* notification = [NSNotification notificationWithName:kWSNotificationFinished(connection.url)
                                                                 object:self
                                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[connection.responseData copy],@"data",[NSNumber numberWithInt:connection.type], @"type", nil]];
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
