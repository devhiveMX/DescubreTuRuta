

#import <Foundation/Foundation.h>
//#import "JSONKit.h"
#import "WebServices.h"
#import <MapKit/MKAnnotation.h>

#define DEBUG_MODE 1


typedef enum {
    WSConnectionTypeNoType = -1,
    WSConnectionTypeLogin,
    WSConnectionTypeLogOut,
    WSConnectionTypeCreateUser,
    WSConnectionTypeUpdateUserAddress,
    WSConnectionTypeUpdateUserProfile,
    WSConnectionTypeGetInfoByZipCode,
    WSConnectionTypeGetAddressHeaders,
    WSConnectionTypePasswordRecovery,
    WSConnectionTypeSendRegistration,
    WSConnectionTypeSavePushToken,
    WSConnectionTypeLocationSearch,
    WSConnectionTypeGoogleTraceroute,
    WSConnectionTypeGoogleTracerouteOnFoot,
    WSConnectionTypeGoogleInverseGeocoding,
}WSConnectionType;


@class WSConnection;
@protocol WSConnectionDelegate <NSObject>

- (void)wsConnectionDidFinishLoading:(WSConnection*)connection;


@optional
- (void)wsConnection:(WSConnection*)connection didReceiveResponse:(NSURLResponse*)response;
- (void)wsConnection:(WSConnection*)connection didFailWithError:(NSError*)error;

@end

@interface WSConnection : NSObject {
    
    NSMutableData *reponseData;
    
    @private
    WSConnectionType wsType;
    NSURL *url;
    NSString *singleParam;
    NSString *jsonParam;
    NSURLConnection *connection;
    NSMutableURLRequest *request;
    CLLocationCoordinate2D originLocation;
    CLLocationCoordinate2D destinationLocation;
    CFTimeInterval connectTime;
    CFTimeInterval responseTime;
    CFTimeInterval responseMilis;
    NSTimer *connectionTimer; 
    
}
@property (nonatomic, readonly, retain) NSMutableData *responseData;
@property (nonatomic, assign) id<WSConnectionDelegate> delegate;
@property (nonatomic, assign) WSConnectionType type;
@property (nonatomic, assign) CFTimeInterval responseMilis;
@property (nonatomic, retain) NSString *singleParam;
@property (nonatomic, retain) NSString *jsonParam;
@property (nonatomic, assign) CLLocationCoordinate2D originLocation;
@property (nonatomic, assign) CLLocationCoordinate2D destinationLocation;
@property (nonatomic, readonly, retain) NSURL *url;

- (id)initWithType:(WSConnectionType)type stringParam:(NSString*)strParam jsonParam:(NSString*)jParam;
- (id)initWithType:(WSConnectionType)type stringParam:(NSString*)strParam jsonParam:(NSString*)jParam delegate:(id<WSConnectionDelegate>)_delegate;
- (id)initWithType:(WSConnectionType)type origin:(CLLocationCoordinate2D)origin destination:(CLLocationCoordinate2D)dest;
- (id)initWithType:(WSConnectionType)type origin:(CLLocationCoordinate2D)origin destination:(CLLocationCoordinate2D)dest delegate:(id<WSConnectionDelegate>)_delegate;

- (void)prepareRequestByType;
- (void)cancel;
- (NSURL *)getURLWithtype;
- (void)connect;
- (void)connectWithType:(WSConnectionType)type stringRequest:(NSString*)param jsonRequest:(NSString*)jParam;
- (CFTimeInterval)responseTimeInMiliseconds ;
- (NSString *)getResponseDataAsJSonString;

+(WSConnection *)connectionWithType:(WSConnectionType)type;
+(WSConnection *)connectionWithType:(WSConnectionType)type stringParam:(NSString *)stringParam jsonParam:(NSString *)jsonParam;
+(WSConnection *)connectionWithType:(WSConnectionType)type stringParam:(NSString *)stringParam jsonParam:(NSString *)jsonParam delegate:(id<WSConnectionDelegate>)delegate;
+(WSConnection *)connectionForInverseGeocodingWithOrigin:(CLLocationCoordinate2D)origin delegate:(id<WSConnectionDelegate>)_delegate;
+(WSConnection *)connectionForTraceRouteFromOrigin:(CLLocationCoordinate2D)origin toDestination:(CLLocationCoordinate2D)destination delegate:(id<WSConnectionDelegate>)_delegate;
+(WSConnection *)connectionForTraceRouteOnFootFromOrigin:(CLLocationCoordinate2D)origin toDestination:(CLLocationCoordinate2D)destination delegate:(id<WSConnectionDelegate>)_delegate;

@end
