//
//  wsConnection.m
//  WalmartApp
//
//  Created by WALMEX3.0_1_WALMART on 19/08/11.
//  Copyright 2011 Walmart Stores Inc. All rights reserved.
//

#import "WSConnection.h"

#define FORCE_CONNECTION_TIMEOUT 0

CFTimeInterval CACurrentMediaTime();

@interface WSConnection() 
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableURLRequest *request;

@end

@implementation WSConnection
@synthesize responseData;
@synthesize delegate;
@synthesize url;
@synthesize connection;
@synthesize jsonParam;
@synthesize singleParam;
@synthesize type = wsType;
@synthesize request;
@synthesize responseMilis;
@synthesize destinationLocation;
@synthesize originLocation;

- (id)init {
    self = [super init];
    if (self) {
        self.destinationLocation = CLLocationCoordinate2DMake(0, 0);
        self.originLocation = CLLocationCoordinate2DMake(0, 0);
        self.jsonParam = nil;
        self.singleParam = nil;
        self.type = WSConnectionTypeNoType;
    }
    return self;
}

- (id)initWithType:(WSConnectionType)type stringParam:(NSString*)strParam jsonParam:(NSString*)jParam {
    self = [self init];
    if (self) {
        self.type = type;
        self.singleParam = strParam;
        //self.jsonParam = jParam;
        NSData *asciiData = [jParam dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        if (asciiData)
            self.jsonParam = [[NSString alloc] initWithData:asciiData encoding:NSISOLatin1StringEncoding];
        [self prepareRequestByType];
    }

    return self;
}

- (id)initWithType:(WSConnectionType)type stringParam:(NSString*)strParam jsonParam:(NSString*)jParam delegate:(id<WSConnectionDelegate>)_delegate{
    self = [self initWithType:type stringParam:strParam jsonParam:jParam];
    if (self) {
        self.delegate = _delegate;
        [self prepareRequestByType];
    }
    return self;
}

- (id)initWithType:(WSConnectionType)type origin:(CLLocationCoordinate2D)origin destination:(CLLocationCoordinate2D)dest {
    self = [self init];
    if (self) {
        self.type = type;
        self.originLocation = origin;
        self.destinationLocation = dest;
    }
    
    return self;
}

- (id)initWithType:(WSConnectionType)type origin:(CLLocationCoordinate2D)origin destination:(CLLocationCoordinate2D)dest delegate:(id<WSConnectionDelegate>)_delegate{
    self = [self initWithType:type origin:origin destination:dest];
    if (self) {
        self.delegate = _delegate;
        [self prepareRequestByType];
    }
    return self;
}

- (void)connectWithType:(WSConnectionType)type stringRequest:(NSString*)param jsonRequest:(NSString*)jParam{
    self.type = type;
    self.singleParam = param;
    self.jsonParam = jParam;
    [self prepareRequestByType];
    [self connect];
}

- (void)dealloc {
    self.responseData = nil;
    self.url = nil;
    [self.connection cancel];
    self.connection = nil;
    self.jsonParam = nil;
    self.singleParam = nil;
    self.delegate = nil;
    self.request = nil;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    if ([connectionTimer isValid])
    {
        [connectionTimer invalidate];
        connectionTimer = [NSTimer scheduledTimerWithTimeInterval:FORCED_CONNECTION_TIMEOUT target:self selector:@selector(connectionTimedOut:) userInfo:nil repeats:NO];
    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary *headers = [httpResponse allHeaderFields];
#if DEBUG_MODE
    NSLog(@"Response: %@", headers);
#endif
    
    if ([connectionTimer isValid])
    {
        [connectionTimer invalidate];
        connectionTimer = [NSTimer scheduledTimerWithTimeInterval:FORCED_CONNECTION_TIMEOUT target:self selector:@selector(connectionTimedOut:) userInfo:nil repeats:NO];
    }
    
    if ([self.delegate respondsToSelector:@selector(wsConnection:didReceiveResponse:)]){
        [self.delegate performSelector:@selector(wsConnection:didReceiveResponse:) withObject:self withObject:response];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if ([connectionTimer isValid])
    {
        [connectionTimer invalidate];
        connectionTimer = [NSTimer scheduledTimerWithTimeInterval:FORCED_CONNECTION_TIMEOUT target:self selector:@selector(connectionTimedOut:) userInfo:nil repeats:NO];
    }
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
#if DEBUG_MODE
    NSString *string = [self getResponseDataAsJSonString];
    NSLog(@"Response json string: %@", string);
#endif
    responseTime = CACurrentMediaTime();
    [connectionTimer invalidate];
    connectionTimer = nil;
    self.responseMilis = [self responseTimeInMiliseconds];
    [[self delegate] performSelector:@selector(wsConnectionDidFinishLoading:) withObject:self];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    responseTime = CACurrentMediaTime();
    [connectionTimer invalidate];
    connectionTimer = nil;
    self.responseMilis = [self responseTimeInMiliseconds];
#if DEBUG_MODE
    NSLog(@"%@", [error localizedDescription]);
#endif
    if ([self.delegate respondsToSelector:@selector(wsConnection:didFailWithError:)]){
        [self.delegate performSelector:@selector(wsConnection:didFailWithError:) withObject:self withObject:error];
    }
    self.connection = nil;
}

- (void)prepareRequestByType {
    self.responseData = [NSMutableData data];
    self.url = [self getURLWithtype];
    self.request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:CONNECTION_TIMEOUT];
    if (self.jsonParam)
    {
        NSData *requestData = [self.jsonParam dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:YES];//[NSData dataWithBytes:[self.jsonParam UTF8String] length:[self.jsonParam length]];
        [self.request setHTTPMethod:@"POST"];
        [self.request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.request setValue:[NSString stringWithFormat:@"%lud", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
        [self.request setHTTPBody: requestData];
        
    }
#if DEBUG_MODE
    NSLog(@"Complete Request: %@", [self.request allHTTPHeaderFields]);
#endif
}

- (void)cancel {
    self.delegate = nil;
    [self.connection cancel];
    if ([connectionTimer isValid])
        [connectionTimer invalidate];
}
     
- (void)connect {
    connectTime = CACurrentMediaTime();
#if FORCE_CONNECTION_TIMEOUT
    connectionTimer = [NSTimer scheduledTimerWithTimeInterval:FORCED_CONNECTION_TIMEOUT target:self selector:@selector(connectionTimedOut:) userInfo:nil repeats:NO];
#endif
    if (!self.connection)
        self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
#if DEBUG_MODE
    NSLog(@"Connecting to: %@", self.url);
    if (self.jsonParam)
    {
        NSLog(@"JSON Request: %@", self.jsonParam);
    }
#endif
}

- (void)connectionTimedOut:(NSTimer*)timer {
    [connectionTimer invalidate];
    connectionTimer = nil;
    self.responseMilis = [self responseTimeInMiliseconds];
    NSMutableString *response = [NSMutableString string];
    [response appendFormat:@"{%c%@%c:%d,",34,@"codeMessage",34,-1000];
    [response appendFormat:@"%c%@%c:%c%@%c}",34,@"message",34,34,@"El tiempo de espera se agotó. Por favor inténtelo más tarde",34];
#if DEBUG_MODE
    NSLog(@"Response: %@", response);
#endif
    self.responseData = [NSMutableData dataWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
    [[self delegate] performSelector:@selector(wsConnectionDidFinishLoading:) withObject:self];
    [self cancel];
    self.connection = nil;
}

- (NSURL *)getURLWithtype {
    NSURL *_url = nil;
    NSString *strURL = nil	;
    switch(self.type) {
            break;
        case WSConnectionTypePasswordRecovery:
            strURL = URL_PASSWORD_RECOVERY;
            break;
        case WSConnectionTypeSavePushToken:
            strURL = URL_SAVE_TOKEN;
            break;
        case WSConnectionTypeGoogleInverseGeocoding:
            strURL = [NSString stringWithFormat:REVERSE_GEOCODING_URL,self.originLocation.latitude, self.originLocation.longitude];
            break;
        case WSConnectionTypeGoogleTraceroute:
            strURL = MAPPIR_ROUTE_URL;
            break;
        case WSConnectionTypeGoogleTracerouteOnFoot:
            if (self.type == WSConnectionTypeGoogleTracerouteOnFoot) {
                strURL = [NSString stringWithFormat:TRACEROUTE_URL,self.originLocation.latitude, self.originLocation.longitude, self.destinationLocation.latitude, self.destinationLocation.longitude];
            } else {
                strURL = [NSString stringWithFormat:TRACEROUTE_URL,self.originLocation.latitude, self.originLocation.longitude, self.destinationLocation.latitude, self.destinationLocation.longitude];
            }
            break;
        case WSConnectionTypeLocationSearch:
            strURL = SEARCH_ROUTE_URL;
            break;
//        case WSConnectionTypePaymentTypeCatalog:
//            strURL = URL_PAY_TYPE_CATALOG;
//            break;
        default:
            break;
    }
    NSString *strFinalURL = nil;
    if (self.type < WSConnectionTypeGoogleInverseGeocoding)
        strFinalURL = [NSString stringWithFormat:@"%@%@", URL_BASE, strURL];
//    else if (self.type < WSConnectionTypeGoogleTraceroute)
//        strFinalURL = strURL;
    else
        strFinalURL = strURL;
    if (self.singleParam) {
        strFinalURL = [strFinalURL stringByAppendingFormat:@"/%@",self.singleParam];
    }
    _url = [NSURL URLWithString:strFinalURL];
    return _url;
}

- (CFTimeInterval)responseTimeInMiliseconds {
    return (responseTime - connectTime)*1000;
}

- (NSString *)getResponseDataAsJSonString {
    return [[NSString alloc] initWithData:self.responseData encoding:NSStringEncodingConversionAllowLossy];
}

+(WSConnection *)connectionWithType:(WSConnectionType)type {
    return  [self connectionWithType:type stringParam:nil jsonParam:nil];
}

+(WSConnection *)connectionWithType:(WSConnectionType)type stringParam:(NSString *)stringParam jsonParam:(NSString *)jsonParam
{   
    return [self connectionWithType:type stringParam:stringParam jsonParam:jsonParam delegate:nil];
}

+(WSConnection *)connectionWithType:(WSConnectionType)type stringParam:(NSString *)stringParam jsonParam:(NSString *)jsonParam delegate:(id<WSConnectionDelegate>)delegate
{   
    return [[self alloc] initWithType:type stringParam:stringParam jsonParam:jsonParam delegate:delegate];
}

+(WSConnection *)connectionForInverseGeocodingWithOrigin:(CLLocationCoordinate2D)origin delegate:(id<WSConnectionDelegate>)_delegate{
    
    return [[self alloc] initWithType:WSConnectionTypeGoogleInverseGeocoding origin:origin destination:CLLocationCoordinate2DMake(0, 0) delegate:_delegate];
}

+(WSConnection *)connectionForTraceRouteFromOrigin:(CLLocationCoordinate2D)origin toDestination:(CLLocationCoordinate2D)destination delegate:(id<WSConnectionDelegate>)_delegate{
    return [[self alloc] initWithType:WSConnectionTypeGoogleTraceroute origin:origin destination:destination delegate:_delegate];
}

+(WSConnection *)connectionForTraceRouteOnFootFromOrigin:(CLLocationCoordinate2D)origin toDestination:(CLLocationCoordinate2D)destination delegate:(id<WSConnectionDelegate>)_delegate{
    return [[self alloc] initWithType:WSConnectionTypeGoogleTracerouteOnFoot origin:origin destination:destination delegate:_delegate];
}

@end
