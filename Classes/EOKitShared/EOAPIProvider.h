//
//  EOProvider.h
//  EOSDK
//
//  Created by Andrew Kopanev on 1/6/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOAPIProviderDelegate.h"
#import "EOAPIConstants.h"

#import <Availability.h>
#import <TargetConditionals.h>

#if !TARGET_OS_IOS
#import <Cocoa/Cocoa.h>
//#import <EOKit/EOAuthWindowControllerOSX.h>
//#import <EOKit/EOAuthorizationViewControllerOSX.h>
#endif

#if TARGET_OS_IOS
//#import <EOKit/EOAuthWindowControllerIOS.h>
//#import <EOKit/EOAuthorizationViewControllerIOS.h>
#endif

#import "EOAuthorizationViewController.h"




@interface EOAPIProvider : NSObject

// Default value is https://start.exactonline.nl/api/v1
@property (nonatomic, strong) NSString				*apiURL;

// Default is https://start.exactonline.nl/api/oauth2/auth
@property (nonatomic, strong) NSString				*oauth2AuthorizationURL;

// Default is https://start.exactonline.nl/api/oauth2/token
@property (nonatomic, strong) NSString				*oauth2TokenURL;

// Default value is grabbed from API 'current/Me' response
// nil until manual setup or 'current/Me' API method response
@property (nonatomic, strong) NSString				*currentDivision;

// Returns access token (if exists).
@property (nonatomic, readonly) NSString			*accessToken;

@property (nonatomic, assign) id <EOAPIProviderDelegate>delegate;

+ (instancetype)providerWithClientId:(NSString *)clientId secret:(NSString *)secret;

// Returns any provider. This method makes sense when you work with one provider only.
// See implementation for further details.
+ (instancetype)anyProvider;

// Designated initializer.
- (instancetype)initWithClientId:(NSString *)clientId secret:(NSString *)secret;

// Authorization
//- (void)authorizeWithCallbackURL:(NSString *)callbackURLString completion:(void(^)(NSError *error))completion;

- (void)authorizeWithCallbackURL:(NSString *)callbackURLString authViewController:(EOAuthorizationViewController *)authorizationViewController completion:(void(^)(NSError *error))completion;

// Logs user out
// Removes stored token information, cancel requests
- (void)logout;

// API
// GET requests
// Uses 'currentDivision' as division
- (NSOperation *)restGetAPI:(NSString *)apiName completion:(EOAPICompletion)completion;

// Uses 'currentDivision' as division
- (NSOperation *)restGetAPI:(NSString *)apiName odataParams:(NSDictionary *)odataParams completion:(EOAPICompletion)completion;

- (NSOperation *)restGetAPI:(NSString *)apiName division:(NSString *)division odataParams:(NSDictionary *)odataParams completion:(EOAPICompletion)completion;
- (NSOperation *)restGetAPI:(NSString *)apiName division:(NSString *)division odataParams:(NSDictionary *)odataParams grabAllItems:(BOOL)grabAllItems completion:(EOAPICompletion)completion;

// Any HTTP request
- (NSOperation *)restAPI:(NSString *)apiName division:(NSString *)division httpMethod:(NSString *)httpMethod httpBody:(NSData *)body httpQuery:(NSString *)query httpHeaders:(NSDictionary *)headers completion:(EOAPICompletion)completion;

@end
