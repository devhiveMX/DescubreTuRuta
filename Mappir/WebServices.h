//
//  WebServices.h
//  WalmartApp
//
//  Created by WALMEX3.0_1_WALMART on 18/08/11.
//  Copyright 2011 Walmart Stores Inc. All rights reserved.
//

#define USE_SUPERAMA_SERVICES   1
#define PRODUCTION_URL          1   
#define CLEAR_SESSION           0 
#define GET_TICKET_BY_POST      1


#if USE_SUPERAMA_SERVICES 

#if PRODUCTION_URL
#define URL_BASE @"https://www.aclaraciones.com.mx/superamamobile/15"
#else
#define URL_BASE @"http://192.168.43.193:8081/superamamobile/15"
#endif

#define URL_STORE_LOCATOR_BASE @"http://192.168.43.193:8081/StoreLocatorApp/storeLocator/byBusiness"

#define URL_ADD_ITEM_TO_LIST                @"/list/addItemToList"
#define URL_ADD_ITEM_TO_SHOPPING_CART       @"/list/addItemToShoppingCartByUpcWithComments"
#define URL_ADD_ITEMS_TO_CART_FROM_LIST     @"/list/addItemsToListFromCart"

#define URL_GET_CATEGORIES_LIST             @"/list/getCategories"
#define URL_GET_ITEM_BY_UPC                 @"/list/getItemByUpc"
#define URL_GET_ITEMS_BY_SEARCH             @"/list/getItemsBySearching"
#define URL_GET_ITEMS_BY_TICKET             @"/list/getItemByTicket"
#define URL_GET_LIST_BY_ID                  @"/list/getListById"
#define URL_GET_LISTS_BY_USER               @"/list/getListsByUser"
#define URL_GET_PURCHASE_HISTORY_BY_USER    @"/list/getPurchaseOrderByUser"
#define URL_GET_SHOPPING_CART               @"/list/getShoppingCartByUser"
#define URL_GET_TIME_BANDS                  @"/list/getTimeBands"
#define URL_GET_DELIVERY_TYPES              @"/list/getDeliveryTypes"
#define URL_GET_ADDRESS_BY_ID               @"/list/getAddressById"
#define URL_GET_ADDRESS_HEADERS             @"/list/getAddressByUser"

#define URL_CREATE_TICKET_LIST              @"/list/createTicketList"
#define URL_SAVE_TICKET_LIST                @"/list/saveList"

#define URL_DELETE_ITEM_BY_UPC              @"/list/deleteItem"
#define URL_DELETE_ITEM_FROM_CART           @"/list/deleteItemToShoppingCartByUpc"
#define URL_DELETE_TICKET_LIST              @"/list/deleteList"

#define URL_CONVERT_CART_TO_LIST            @"/list/convertShoppingCartToList"
#define URL_CONVERT_LIST_TO_CART            @"/list/convertListToShoppingCart"

#define URL_UPDATE_ITEM_BY_ITEM             @"/list/updateItem"
#define URL_UPDATE_SHOPPING_CART_ITEM       @"/list/updateShoppingCartItem"
#define URL_UPDATE_TICKET_LIST              @"/list/updateList"
#define URL_UPDATE_USER_ADDRESS             @"/list/updateUserAddress"
#define URL_UPDATE_USER_PROFILE             @"/list/updateUserProfile"

#define URL_SEND_LIST_BY_EMAIL              @"/list/sendListByEmail"
#define URL_SEND_ORDER_BY_EMAIL             @"/list/sendOrderByEmail"


#define URL_LOGIN                           @"/login"
#define URL_LOGOUT                          @"/logout"
#define URL_SEND_REGISTRATION               @"/login/userRegistry"
#define URL_GET_INFO_BY_ZIPCODE             @"/login/getInfoByZipCode"
#define URL_SAVE_TOKEN                      @"/login/saveToken"
#define URL_GET_ADDRESS_BY_USER             @"/list/getAddressByUser"
#define URL_CREATE_USER                     @"/login/altaLogin"
#define URL_PASSWORD_RECOVERY               @"/login/passwordRecovery"

#define URL_PAY_TYPE_CATALOG                @"/list/getCatPaymentType"
#define URL_DEL_TYPE_CATALOG                @"/list/getCatDeliveryType"

#define URL_ACCOUNT                         @"https://www.walmartonline.com.ar/m_ingresarapp.aspx"  

#else

#if PRODUCTION_URL
#define URL_BASE @"https://www.aclaraciones.com.mx/argentinamovil"
#else
#define URL_BASE @"http://192.168.43.192:8080/argentinamovil"
#endif

#define URL_STORE_LOCATOR_BASE @"http://192.168.43.192:8080/StoreLocatorApp/storeLocator/byBusiness"

#define URL_ADD_ITEM_TO_LIST      @"/ticketList/addItemToList"
#define URL_ADD_ITEM_TO_SHOPPING_CART @"/ticketList/addItemToShoppingCartByUpc"

#define URL_GET_ITEM_BY_UPC         @"/ticketList/getItemByUpc"
#define URL_GET_LIST_BY_ID          @"/ticketList/getTicketListById"
#define URL_GET_LISTS_BY_USER       @"/ticketList/getTicketListByUser"
#define URL_GET_PURCHASE_HISTORY_BY_USER @"/ticketList/getPurchaseOrderByUser"
#define URL_GET_CATEGORIES_LIST     @"/ticketList/getCategoryList"
#define URL_GET_SHOPPING_CART       @"/ticketList/getShoppingCartByUser"
#define URL_GET_TIME_BANDS          @"/ticketList/getTimeBands"

#define URL_CREATE_TICKET_LIST      @"/ticketList/createTicketList"
#define URL_SAVE_TICKET_LIST        @"/ticketList/saveTicketList"

#define URL_DELETE_TICKET_LIST      @"/ticketList/deleteTicketList"
#define URL_DELETE_ITEM_BY_UPC      @"/ticketList/deleteItem"
#define URL_DELETE_ITEM_FROM_CART   @"/ticketList/deleteItemToShoppingCartByUpc"

#define URL_CONVERT_CART_TO_LIST    @"/ticketList/convertShoppingCartToList"
#define URL_CONVERT_LIST_TO_CART    @"/ticketList/convertListToShoppingCart"

#define URL_UPDATE_USER_ADDRESS     @"/list/updateUserAddress"
#define URL_UPDATE_ITEM_BY_ITEM     @"/ticketList/updateItem"
#define URL_UPDATE_SHOPPING_CART_ITEM @"/ticketList/updateShoppingCartItem"
#define URL_UPDATE_TICKET_LIST      @"/ticketList/updateTicketList"


#define URL_SEND_LIST_BY_EMAIL      @"/ticketList/sendMail"
#define URL_SEND_ORDER_BY_EMAIL     @"/ticketList/sendOrderByMail"

#define URL_GET_ITEMS_BY_SEARCH     @"/ticketList/getItemsBySearching"


#define URL_LOGIN                   @"/login"
#define URL_CREATE_USER             @"/login/altaLogin"
#define URL_LOGOUT                  @"/login/logout"

#define URL_PAY_TYPE_CATALOG        @"/ticketList/getCatPaymentType"
#define URL_DEL_TYPE_CATALOG        @"/ticketList/getCatDeliveryType"

#define URL_ACCOUNT                 @"https://www.walmartonline.com.ar/m_ingresarapp.aspx"

#endif


#define GOOGLE_API_INV_GEOCODING_URL @"http://maps.google.com/maps/api/geocode/json?latlng=%f,%f&sensor=false"
#define GOOGLE_API_TRACEROUTE_URL @"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true&language=es"

#define GOOGLE_API_TRACEROUTE_ONFOOT_URL @"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&mode=walking&sensor=true&language=es"

#define CLLocationCoordinate2DZero CLLocationCoordinate2DMake(0,0)

#define ALERTVIEW_TITLE @"Superama Móvil"
#define ALERTVIEW_MINOR_AGE_MSG @"Disponible sólo para mayores de edad."
#define CONNECTION_ERROR_MESSAGE @"No se pudo conectar a internet en este momento. Por favor inténtelo de nuevo más tarde."
#define INVALID_TICKET_MESSAGE @"El ticket no se encuentra disponible por el momento.\nPor favor inténtalo de nuevo más tarde."
#define ERROR_USER_NOT_IN_SESSION @"La sesión ha expirado. La aplicación se cerrará"
#define OUT_OF_STOCK_STRING @"No disponible"

#define CONNECTION_TIMEOUT 60   
#define FORCED_CONNECTION_TIMEOUT 45

typedef enum {
    LoginErrorTypeError = -10,
    LoginErrorTypeBlocked = -3,
    LoginErrorTypeMailNotValidated,
    LoginErrorTypeUserNotRegistered = -1,
    LoginErrorTypeSuccess,
    LoginErrorTypeSuccessNoList,
} LoginErrorType;