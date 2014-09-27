//
//  GPSLocationsParser.m
//  HeartsLocator
//
//  Created by Leonardo Cid on 04/07/11.
//  Copyright 2011 Latino Mobile. All rights reserved.
//

#import "GPSLocationsParser.h"
#import "StoreLocation.h"

@implementation GPSLocationsParser

@synthesize responseData;
@synthesize results;
@synthesize delegate = _delegate;
@synthesize currentLocationDict;
@synthesize xmlParser;
@synthesize connection;
- (void)parseXMLAtURL:(NSString *)URL { 
	
	self.responseData = nil;
	self.results = nil;
	self.responseData = [NSMutableData data];
	
	NSURL *baseURL = [NSURL URLWithString:URL];
	
	
	NSURLRequest *request = [NSURLRequest requestWithURL:baseURL];
	
	self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
}

- (void)parseXMLAtLocalURL:(NSString *)URL { 
	
	self.responseData = nil;
	self.results = nil;
	self.responseData = [NSMutableData data];
	
	NSURL *baseURL = [NSURL URLWithString:URL];
	
	
	NSURLRequest *request = [NSURLRequest requestWithURL:baseURL];
	
	self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if ([self.delegate respondsToSelector:@selector(calendarParser:didFailToWithError:)]) {
		[self.delegate gpsLocationsParser:self didFailToWithError:error];
	} else {
		NSString * errorString = [NSString stringWithFormat:@"Por favor inténtelo más tarde"];
		UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Hubo un error al descargar la informacion" message:errorString delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
		[errorAlert show];
	}
    self.connection = nil;
}

 - (void)connectionDidFinishLoading:(NSURLConnection *)connection
 {
 //self.results = [[[NSMutableArray alloc] init] autorelease];
     self.xmlParser = nil;
     self.xmlParser = [[NSXMLParser alloc] initWithData:responseData];
 
     [self.xmlParser setDelegate:self];
 
     [self.xmlParser setShouldProcessNamespaces:NO]; 
     [self.xmlParser setShouldReportNamespacePrefixes:NO]; 
     [self.xmlParser setShouldResolveExternalEntities:NO];
     [self.xmlParser parse];
     self.connection = nil;
 }
 

- (void)parseXMLFileAtURL:(NSString *)URL
{
	
	self.responseData = nil;
	self.results = nil;
	
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",URL] ofType:@"xml"];
#if DEBUG_MODE
    NSLog(@"URL: %@",filePath);
#endif
	
	NSData *xmlData = [NSData dataWithContentsOfFile:filePath];
	
	//self.responseData = [xmlData mutableCopy];
	
	self.results = [[NSMutableArray alloc] init];
	self.xmlParser = nil;
	self.xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
	
	[self.xmlParser setDelegate:self];
	
	[self.xmlParser setShouldProcessNamespaces:NO]; 
	[self.xmlParser setShouldReportNamespacePrefixes:NO]; 
	[self.xmlParser setShouldResolveExternalEntities:NO];
	[self.xmlParser parse];
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser { 
	NSLog(@"found file and started parsing"); 
} 

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError { 
	NSString * errorString = [NSString stringWithFormat:@"No se pudo descargar el contenido de la pagina (Error code %i )", [parseError code]]; 
	NSLog(@"error parsing XML: %@", errorString); 
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error al cargar contenido" message:errorString delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles:nil]; 
	[errorAlert show];
    self.xmlParser = nil;
} 

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{ 
	currentTagName = elementName; 
	
	if ([elementName isEqualToString:@"store"]) {
		self.currentLocationDict = [NSMutableDictionary dictionary];        
	} else if ([elementName isEqualToString:@"stores"]) { 
		self.results = [[NSMutableArray alloc] init];
	} else if ([elementName isEqualToString:@"businessid"]) {
		currentContent = [[NSMutableString alloc] init];
	} else if ([elementName isEqualToString:@"storeid"]) {
		currentContent = [[NSMutableString alloc] init];
	} else if ([elementName isEqualToString:@"name"]) {
		currentContent = [[NSMutableString alloc] init];
	} else if ([elementName isEqualToString:@"address"]) {
		currentContent = [[NSMutableString alloc] init];
	} else if ([elementName isEqualToString:@"latpoint"]) {
		currentContent = [[NSMutableString alloc] init];
	} else if ([elementName isEqualToString:@"lonpoint"]) {
		currentContent = [[NSMutableString alloc] init];
	} else if ([elementName isEqualToString:@"telephone"]) {
		
	} else if ([elementName isEqualToString:@"zipcode"]) {
		
	} else if ([elementName isEqualToString:@"opens"]) {
		currentContent = [[NSMutableString alloc] init];
	}
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{ 
	//NSLog(@"ended element: %@", elementName); 
	
	if ([elementName isEqualToString:@"store"]) {
        if (![[self.currentLocationDict objectForKey:@"latpoint"] isEqualToString:@"NULL"])
            [self.results addObject:[StoreLocation locationWithDictionary:self.currentLocationDict]];
	} else if ([elementName isEqualToString:@"businessid"]) {
		[self.currentLocationDict setObject:currentContent forKey:elementName];
	} else if ([elementName isEqualToString:@"storeid"]) {
		[self.currentLocationDict setObject:currentContent forKey:elementName];
	} else if ([elementName isEqualToString:@"name"]) {
		[self.currentLocationDict setObject:currentContent forKey:elementName];
	} else if ([elementName isEqualToString:@"address"]) {
		[self.currentLocationDict setObject:currentContent forKey:elementName];	
	} else if ([elementName isEqualToString:@"latpoint"]) {
		[self.currentLocationDict setObject:currentContent forKey:elementName];
	} else if ([elementName isEqualToString:@"lonpoint"]) {
		[self.currentLocationDict setObject:currentContent forKey:elementName];
	} else if ([elementName isEqualToString:@"telephone"]) {
		
	} else if ([elementName isEqualToString:@"zipcode"]) {
		
	} else if ([elementName isEqualToString:@"opens"]) {
		[self.currentLocationDict setObject:currentContent forKey:elementName];
	}
} 

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{ 
	if ([currentTagName isEqualToString:@"businessid"] || [currentTagName isEqualToString:@"storeid"] || [currentTagName isEqualToString:@"name"] || [currentTagName isEqualToString:@"address"] || [currentTagName isEqualToString:@"latpoint"] || [currentTagName isEqualToString:@"lonpoint"] || [currentTagName isEqualToString:@"opens"] ) {
        //NSString *aString = [[[NSString alloc] initWithData: [string dataUsingEncoding:NSISOLatin1StringEncoding] encoding:NSUTF8StringEncoding] autorelease];
        //NSLog(@"Content: %@", string);
        //if (aString)
        [currentContent appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        //else
        //    NSLog(@"Content: %@", string);
            
	}
} 

- (void)parserDidEndDocument:(NSXMLParser *)parser { 
	[self.delegate performSelector:@selector(gpsLocationsParserDidFinishParse:) withObject:self];
    self.xmlParser = nil;
}

- (void)dealloc {
	_delegate = nil;
	[self.xmlParser abortParsing];
	self.xmlParser.delegate = nil;
	self.xmlParser = nil;
    self.responseData = nil;
	self.results = nil;
    self.currentLocationDict = nil;
}

- (void)cancel {
    [self.connection cancel];
    self.connection = nil;
    [self.xmlParser abortParsing];
    self.xmlParser = nil;
}

+ (GPSLocationsParser*)parser {
    return [[self alloc] init];
}

@end
