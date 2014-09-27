//
//  NSString+IsNumber.h
//  WalmartApp
//
//  Created by WALMEX3.0_1_WALMART on 04/10/11.
//  Copyright 2011 Walmart Stores Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define REGEX_CUSTOM_NAME @"[A-Za-z0-9ñÑÁáÉéÍíÓóÚú _-]{0,250}"
#define REGEX_REGSITRATION_INFO @"[A-Za-z0-9ñÑÁáÉéÍíÓóÚú _-]{0,125}"
#define REGEX_CUST_NAME_NO_SP_CHAR @"^[a-zA-Z0-9-_ ]{0,250}$"
#define REGEX_PASSWORD @"^[a-zA-Z0-9]{8,16}$"
#define REGEX_QTY_NO_POINT @"^\\d{0,2}[0-9]?$"
#define REGEX_QTY_POINT @"^\\d{0,2}[0-9](\\.\\d{0,1}[0-9])?$"
#define REGEX_TELEPHONE @"[0-9]{10}"
#define REGEX_ZIPCODE @"[0-9]{0,5}"
#define REGEX_EMAIL @"[A-Z0-9a-z._%+-]+@([A-Za-z0-9-])+(.([A-Za-z-]{2,})){1,}"
#define REGEX_TICKET @"[0-9]{,13}"
//#define REGEX_COMMENTS @"^[^<>=]*$"
//#define REGEX_COMMENTS @"[A-Za-z0-9ñÑÁáÉéÍíÓóÚú .:_-]{0,250}"
#define REGEX_COMMENTS @"(^$|^[a-zA-Z\\(\\)\\[\\] ·ÈÌÛ˙¡…Õ”⁄Ò—¸‹&,:.@0-9/?\\w\\-+]+$)"
@interface NSString (NSString_IsNumber)
- (BOOL)isNumberOfMaxLength:(NSInteger)length;
- (BOOL)isNumberOfMinLength:(NSInteger)minLen andMaxLength:(NSInteger)maxLen;


- (NSString *)stringByConvertingHTMLToPlainText;
- (NSString *)stringByDecodingHTMLEntities;
- (NSString *)stringByEncodingHTMLEntities;
- (NSString *)stringWithNewLinesAsBRs;
- (NSString *)stringByRemovingNewLinesAndWhitespace;
- (NSString *)stringByLinkifyingURLs;

- (NSString*)stringByConvertingToISoLatin;
- (BOOL)isRegexValid:(NSString*)regex;
// DEPRECIATED - Please use NSString stringByConvertingHTMLToPlainText
- (NSString *)stringByStrippingTags __attribute__((deprecated));
+ (NSString*)stringByFormattingNumberNumber:(CGFloat)number withFormatterStyle:(NSNumberFormatterStyle)style;
@end
