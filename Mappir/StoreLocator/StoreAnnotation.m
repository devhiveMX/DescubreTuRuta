

#import "StoreAnnotation.h"
#import "StoreLocation.h"

@interface StoreAnnotation() 
@property (nonatomic, assign) StoreType storeType;
@property (nonatomic, retain) UIImageView *leftCalloutView;
@end


@implementation StoreAnnotation

@synthesize location;
@synthesize storeType;
@synthesize leftCalloutView;


- (id) initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if ( self ) {
        self.location = [StoreLocation locationWithDictionary:dict];
        self.storeType = [StoreAnnotation getTypeFromString:[StoreLocation getTypeFromLocationStoreType:self.location.type]];
        self.leftCalloutView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[StoreAnnotation getImageNameFromType:storeType]]];

    }
    
    return self;
}

- (id) initWithStoreLocation:(StoreLocation *)_location {
    self = [super init];
    if ( self ) {
        self.location = _location;
        self.storeType = [StoreAnnotation getTypeFromString:[StoreLocation getTypeFromLocationStoreType:self.location.type]];
        self.leftCalloutView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[StoreAnnotation getImageNameFromType:storeType]]] ;
        self.leftCalloutView.frame = CGRectMake(0, 0, 32, 32);
    }
    return self;
}

- (void) dealloc {
    self.location = nil;
    self.leftCalloutView= nil;
}

#pragma mark -
#pragma mark Callout methods

- (NSString *) title {
	
    return self.location.storeName;
}

- (NSString *) subtitle {
	return self.location.storeAddress;
}

- (StoreType)type {
    return storeType;
}

- (CLLocationCoordinate2D) coordinate {
    return self.location.coordinate;
}

- (void)updateLocation:(StoreLocation *)_location {
    self.location = _location;
    self.storeType = [StoreAnnotation getTypeFromString:[StoreLocation getTypeFromLocationStoreType:self.location.type]];
    [(UIImageView *)self.leftCalloutView setImage: [UIImage imageNamed:[StoreAnnotation getImageNameFromType:storeType]]];
}

- (NSString*)getImageNameFromType {
    switch (storeType) {
        case StoreTypeWalmart:
            return @"indicador_walmart.png";
            break;
        case StoreTypeSamsClub:
            return @"indicador_sams.png";
            break;
        case StoreTypeSuburbia:
            return @"indicador_suburbia.png";
            break;
        case StoreTypeElPorton:
            return @"indicador_porton.png";
            break;
        case StoreTypeAurrera:
            return @"indicador_aurrera.png";
            break;
        case StoreTypeVips:
            return @"indicador_vips.png";
            break;
        case StoreTypeSuperama:
            return @"indicador_superama.png";            
            break;
        default:
            break;
    }
    return nil;
}

- (NSString *)getTypeAsString {
    return [StoreAnnotation getStoreNameFromType:self.storeType];
}

+ (StoreType)getTypeFromString:(NSString*)stringType {
    if ([stringType isEqualToString:@"wal"]) {
        return StoreTypeWalmart;
    } else if ([stringType isEqualToString:@"sam"]) {
        return StoreTypeSamsClub;
    } else if ([stringType isEqualToString:@"sub"]) {
        return StoreTypeSuburbia;
    } else if ([stringType isEqualToString:@"por"]) {
        return StoreTypeElPorton;
    } else if ([stringType isEqualToString:@"aur"]) {
        return StoreTypeAurrera;
    } else if ([stringType isEqualToString:@"vip"]) {
        return StoreTypeVips;
    } else if ([stringType isEqualToString:@"sup"]) {
        return StoreTypeSuperama;
    }
    return StoreTypeNoType;
}

+ (StoreType)getTypeFromLocationType:(NSInteger)type {
    switch(type) {
        case BusinessIDSams:
            return StoreTypeSamsClub;
        case BusinessIDSupercenter:
            return StoreTypeWalmart;
        case BusinessIDSuperama:
            return StoreTypeSuperama;
        default:
            return StoreTypeNoType;
    }
}

+ (NSInteger)getLocationTypeFromStoreType:(StoreType)type {
    switch(type) {
        case StoreTypeSamsClub:
            return BusinessIDSams;
        case StoreTypeWalmart:
            return BusinessIDSupercenter;
        case StoreTypeSuperama:
            return BusinessIDSuperama;
        default:
            return StoreTypeNoType;
    }
}

+ (NSString*)getImageNameFromType:(StoreType) type {
    switch (type) {
        case StoreTypeWalmart:
            return @"logo_walmart-gris.png";
            break;
        case StoreTypeSamsClub:
            return @"logo_sams-gris.png";
            break;
        case StoreTypeSuburbia:
            return @"logo_suburbia-gris.png";
            break;
        case StoreTypeElPorton:
            return @"logo_porton-gris.png";
            break;
        case StoreTypeAurrera:
            return @"logo_aurrera-gris.png";
            break;
        case StoreTypeVips:
            return @"logo_vips-gris.png";
            break;
        case StoreTypeSuperama:
            return @"logo_superama-gris.png";
        default:
            break;
    }
    return nil;
}

+(UIImage *)getImageFromType:(StoreType)type {
    UIImage *image = nil;
    if (type == StoreTypeNoType) return nil;
    //if (!images[type]) {
        image = [UIImage imageNamed:[StoreAnnotation getImageNameFromType:type]];
        //images[type] = [image retain];
    //} else {
        //image = images[type];
    //}
    return image;
}

+ (NSString *)getStoreNameFromType:(StoreType)type {
    switch (type) {
        case StoreTypeWalmart:
            return @"Walmart";
            break;
        case StoreTypeSamsClub:
            return @"Sam's Club";
            break;
        case StoreTypeSuburbia:
            return @"Suburbia";
            break;
        case StoreTypeElPorton:
            return @"El Portón";
            break;
        case StoreTypeAurrera:
            return @"Bodega Aurrera";
            break;
        case StoreTypeVips:
            return @"Vips";
            break;
        case StoreTypeSuperama:
            return @"Superama";
            break;    
        default:
            break;
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{\n\tName: \"%@\",\n\tAddress: \"%@\"\n\tStore Type: %@\n}", self.location.storeName, self.location.storeAddress, [StoreAnnotation getStoreNameFromType:self.storeType]];
}


@end
