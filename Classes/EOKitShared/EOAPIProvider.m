//
//  EOProvider.m
//  EOSDK
//
//  Created by Andrew Kopanev on 1/6/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#import "EOAPIProvider.h"
//#import "EOAuthorizationViewController.h"

#import "AFNetworking.h"
#import "AFOAuth2Manager.h"

#import "EOJSONResponseSerializer.h"
#import "EORESTRequestInfo.h"

// Error domains
NSString *const EOAPIProviderErrorDomain			= @"EOAPIProviderErrorDomain";
NSString *const EOAPIErrorDomain					= @"EOAPIErrorDomain";

// Endpoints
NSString *const EOAPIDefaultURL						= @"https://start.exactonline.nl/api/v1";
NSString *const EOOAuth2AuthURL						= @"https://start.exactonline.nl/api/oauth2/auth";
NSString *const EOOAuth2TokenURL					= @"https://start.exactonline.nl/api/oauth2/token";

@interface EOAPIProvider () <EOAuthorizationViewControllerDelegate>
//@interface EOAPIProvider ()

@property (nonatomic, strong) NSString				*clientId;
@property (nonatomic, strong) NSString				*secret;
@property (nonatomic, strong) AFOAuthCredential		*credential;

@property (nonatomic, strong) NSOperationQueue		*requestsQueue;
@property (nonatomic, strong) NSMutableArray		*postponedRequests;
@property (nonatomic, strong) AFOAuth2Manager		*refreshTokenManager;

@property (nonatomic, copy) void (^authorizationCompletion)(NSError *error);

@end

@implementation EOAPIProvider

#pragma mark -

static NSMutableDictionary *providersDictionary = nil;

+ (instancetype)providerWithClientId:(NSString *)clientId secret:(NSString *)secret {
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		providersDictionary = [NSMutableDictionary new];
	});
	
	@synchronized(self) {
		if (!providersDictionary[clientId]) {
			EOAPIProvider *provider = [[EOAPIProvider alloc] initWithClientId:clientId secret:secret];
			providersDictionary[clientId] = provider;
		}
	}
	return providersDictionary[clientId];
}

+ (instancetype)anyProvider {
	return ([[providersDictionary allValues] firstObject]);
}

#pragma mark -

- (instancetype)initWithClientId:(NSString *)clientId secret:(NSString *)secret {
	if (self = [super init]) {
		
		assert( clientId != nil && secret != nil );
		
		self.postponedRequests = [NSMutableArray array];
		self.clientId = clientId;
		self.secret = secret;
		self.apiURL = EOAPIDefaultURL;
		self.oauth2AuthorizationURL = EOOAuth2AuthURL;
		self.oauth2TokenURL = EOOAuth2TokenURL;
		self.credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.clientId];
		
		self.requestsQueue = [NSOperationQueue new];
		[self.requestsQueue setMaxConcurrentOperationCount:3];
	}
	return self;
}

- (NSString *)accessToken {
	return self.credential.accessToken.copy;
}

#pragma mark - API

#pragma mark * authorization


- (void)authorizeWithCallbackURL:(NSString *)callbackURLString authViewController:(EOAuthorizationViewController *)authorizationViewController completion:(void(^)(NSError *error))completion {
    
    assert( callbackURLString != nil );
    
    self.authorizationCompletion = completion;
    
    NSLog(@"crd1: %@",self.credential);

    if (!self.credential) {
        
        authorizationViewController.delegate = self;
        
        [authorizationViewController authorizeWithClientId:self.clientId authorizationURL:self.oauth2AuthorizationURL redirectURL:callbackURLString];
    } else {
        NSLog(@"crd2: %@",self.credential);
        [self completeAuthorizationWithCredentials:self.credential error:nil];
    }
}

- (void)logout {
	// remove credentials
	[AFOAuthCredential deleteCredentialWithIdentifier:self.clientId];
	
	// clear cookies
	NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for (NSHTTPCookie *each in [[cookieStorage cookiesForURL: [NSURL URLWithString: self.apiURL] ] copy]) {
		[cookieStorage deleteCookie:each];
	}
	
	[self.postponedRequests removeAllObjects];
	
	// cancel all operations
	for (AFHTTPRequestOperation *operation in self.requestsQueue.operations) {
		// clear completions, we don't want callbacks
		EORequestInfo *rInfo = operation.userInfo[@"requestInfo"];
		rInfo.completion = nil;
	}
	[self.requestsQueue cancelAllOperations];
}

- (void)completeAuthorizationWithCredentials:(AFOAuthCredential *)credentials error:(NSError *)error {
	// store credentials
	if (credentials && !error) {
		[AFOAuthCredential storeCredential:credentials withIdentifier:self.clientId];
		self.credential = credentials;
	} else {
		[AFOAuthCredential deleteCredentialWithIdentifier:self.clientId];
		self.credential = nil;
	}
	
	
	// call completion
	if (self.authorizationCompletion) {
		self.authorizationCompletion(error);
	}
	self.authorizationCompletion = nil;
}

#pragma mark * EOAuthorizationViewControllerDelegate




- (void)eoAuthorizationViewController:(EOAuthorizationViewController *)viewController didFinishWithResponse:(NSString *)response error:(NSError *)error {
	
	if (!error && response) {
		[self oauthGetTokenWithCode:[response stringByRemovingPercentEncoding] callbackURL:viewController.redirectURL];
	} else {
		error = error ?: [NSError errorWithDomain:EOAPIProviderErrorDomain code:EOAPIProviderAuthorizationBadParams userInfo:nil];
		[self completeAuthorizationWithCredentials:nil error:error];
	}
}




#pragma mark * oauth2

- (void)oauthGetTokenWithCode:(NSString *)code callbackURL:(NSString *)callbackURL {
	AFOAuth2Client *client = [AFOAuth2Client clientWithBaseURL:nil clientID:self.clientId secret:self.secret];
	[client authenticateUsingOAuthWithURLString:self.oauth2TokenURL
										   code:code
									redirectURI:callbackURL
										success:^(AFOAuthCredential *credential) {
											[self completeAuthorizationWithCredentials:credential error:nil];
										} failure:^(NSError *error) {
											[self completeAuthorizationWithCredentials:nil error:error];
										}];
}

- (void)oauthRefreshToken {
	// TODO: this method could be called twice
	
	// refresh token
	__block EOAPIProvider *selfRef = self;
	self.refreshTokenManager = [AFOAuth2Client clientWithBaseURL:nil clientID:self.clientId secret:self.secret];
	[self.refreshTokenManager authenticateUsingOAuthWithURLString:self.oauth2TokenURL
								   refreshToken:self.credential.refreshToken
										success:^(AFOAuthCredential *credential) {
											selfRef.refreshTokenManager = nil;
											[self completeAuthorizationWithCredentials:credential error:nil];
											[self queuePostponedRequests];
										}
										failure:^(NSError *error) {
											selfRef.refreshTokenManager = nil;
											[self failPostponedRequests];
										}];
}

#pragma mark * refreshing stuff

- (void)postponeRequestInfo:(EORequestInfo *)requestInfo {
	@synchronized(self) {
		[self.postponedRequests addObject:requestInfo];
	}
}

- (void)failRequestInfo:(EORequestInfo *)requestInfo {
	if (requestInfo.completion) {
		requestInfo.completion(nil, [NSError errorWithDomain:EOAPIErrorDomain code:401 userInfo:nil]);
	}
}

- (void)queuePostponedRequests {
	@synchronized(self) {
		for (EORequestInfo *requestInfo in self.postponedRequests) {
			[self queueRequestInfo:requestInfo];
		}
		[self.postponedRequests removeAllObjects];
	}
}

- (void)failPostponedRequests {
	@synchronized(self) {
		for (EORequestInfo *requestInfo in self.postponedRequests) {
			[self failRequestInfo:requestInfo];
		}
		[self.postponedRequests removeAllObjects];
	}
}

#pragma mark - API

#pragma mark * common

- (void)updateCurrentDivisionIfNeeded:(EORESTRequestInfo *)requestInfo responseObject:(NSDictionary *)responseObject {
	if (!self.currentDivision && [requestInfo isKindOfClass:[EORESTRequestInfo class]] && requestInfo.isMeAPIMethod && [responseObject isKindOfClass:[NSDictionary class]]) {
		NSArray *results = responseObject[@"d"][@"results"];
		if ([results isKindOfClass:[NSArray class]]) {
			NSDictionary *anyUser = [results firstObject];
			NSString *currentDivision = [anyUser isKindOfClass:[NSDictionary class]] ? anyUser[@"CurrentDivision"] : nil;
			if (currentDivision) {
				self.currentDivision = currentDivision;
			}
		}
	}
}

- (NSString *)restURLForAPIWithName:(NSString *)apiName {
	NSMutableString *string = [NSMutableString stringWithString:self.apiURL];
	if (self.currentDivision && [apiName rangeOfString:@"current/Me"].location == NSNotFound) {
		[string appendFormat:@"/%@", self.currentDivision];
	}
	[string appendFormat:@"%@%@", [apiName hasPrefix:@"/"] ? @"" : @"/", apiName];
	return string;
}

- (NSOperation *)queueRequestInfo:(EORequestInfo *)requestInfo {
	if (self.refreshTokenManager != nil) {
		[self postponeRequestInfo:requestInfo];
		
		// TODO: this is not a good solution, please think how to avoid this situation
		return nil;
	} else {
		// setup appropriate header values
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestInfo.resultURL]];
		NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:requestInfo.requestSpecificHeaders];
		[headers addEntriesFromDictionary:requestInfo.httpHeaders];
		for (NSString *key in headers) {
			[request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
		}
		
		request.HTTPMethod = requestInfo.httpMethod;
		
		// setup authorization token
		if (self.credential) {
			[request setValue:[NSString stringWithFormat:@"Bearer %@", self.credential.accessToken] forHTTPHeaderField:@"Authorization"];
		}
		
		// setup body
		if (requestInfo.body) {
			request.HTTPBody = requestInfo.body;
		}
		
		// queue request
		__block EOAPIProvider *selfRef = self;
		AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
		requestOperation.responseSerializer = [EOJSONResponseSerializer serializer];
		requestOperation.userInfo = @{ @"requestInfo" : requestInfo };
		if ([requestInfo isKindOfClass:[EORESTRequestInfo class]]) {
			[requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
				EORESTRequestInfo *rInfo = operation.userInfo[@"requestInfo"];
				// update currentDivision if needed
				[selfRef updateCurrentDivisionIfNeeded:rInfo responseObject:responseObject];
				
				// append results
				if (!rInfo.results) {
					rInfo.results = [NSMutableArray array];
				}
				[rInfo.results addObjectsFromArray:responseObject[@"d"][@"results"]];
				
				BOOL isRequestDone = YES;
				if (rInfo.shouldRequestAllItems) {
					if (responseObject[@"d"][@"__next"] != nil) {
						NSString *nextURL = responseObject[@"d"][@"__next"];
						rInfo.nextURL = nextURL;
						isRequestDone = NO;
					}
				}
				
				if (isRequestDone) {
					if (rInfo.completion) {
						rInfo.completion(rInfo.results, nil);
					}
				} else {
					[selfRef queueRequestInfo:rInfo];
				}
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				EORequestInfo *rInfo = operation.userInfo[@"requestInfo"];
				if (401 == operation.response.statusCode && self.credential) {
					// seems like token expired
					[selfRef postponeRequestInfo:rInfo];
					[selfRef oauthRefreshToken];
				} else {
					if (rInfo.completion) {
						rInfo.completion(nil, error);
					}
				}
			}];
		} else {
			// deal with XML / csv...
		}
		
		[self.requestsQueue addOperation:requestOperation];
		return requestOperation;
	}
}

#pragma mark * REST

- (NSOperation *)restGetAPI:(NSString *)apiName completion:(EOAPICompletion)completion {
	return [self restGetAPI:apiName division:self.currentDivision odataParams:nil completion:completion];
}

- (NSOperation *)restGetAPI:(NSString *)apiName odataParams:(NSDictionary *)odataParams completion:(EOAPICompletion)completion {
	return [self restGetAPI:apiName division:self.currentDivision odataParams:odataParams completion:completion];
}

- (NSOperation *)restGetAPI:(NSString *)apiName division:(NSString *)division odataParams:(NSDictionary *)odataParams completion:(EOAPICompletion)completion {
	return [self restGetAPI:apiName division:division odataParams:odataParams grabAllItems:NO completion:completion];
}

- (NSOperation *)restGetAPI:(NSString *)apiName division:(NSString *)division odataParams:(NSDictionary *)odataParams grabAllItems:(BOOL)grabAllItems completion:(EOAPICompletion)completion {
	NSMutableString *query = nil;
	if (odataParams.count) {
		query = [NSMutableString string];
		for (NSString *key in odataParams.allKeys) {
			[query appendFormat:@"%@=%@", key, odataParams[key]];
		}
	}
	return [self restAPI:apiName division:division httpMethod:@"GET" httpBody:nil httpQuery:query httpHeaders:nil grabAllItems:grabAllItems completion:completion];
}

- (NSOperation *)restAPI:(NSString *)apiName division:(NSString *)division httpMethod:(NSString *)httpMethod httpBody:(NSData *)body httpQuery:(NSString *)query httpHeaders:(NSDictionary *)headers completion:(EOAPICompletion)completion {
	return [self restAPI:apiName division:division httpMethod:httpMethod httpBody:body httpQuery:query httpHeaders:headers grabAllItems:NO completion:completion];
}

- (NSOperation *)restAPI:(NSString *)apiName division:(NSString *)division httpMethod:(NSString *)httpMethod httpBody:(NSData *)body httpQuery:(NSString *)query httpHeaders:(NSDictionary *)headers grabAllItems:(BOOL)grabAllItems completion:(EOAPICompletion)completion {
	EORESTRequestInfo *requestInfo = [EORESTRequestInfo new];
	requestInfo.httpMethod = [httpMethod uppercaseString];
	requestInfo.body = body;
	requestInfo.query = query;
	requestInfo.httpHeaders = headers;
	requestInfo.apiURL = [self restURLForAPIWithName:apiName];
	requestInfo.completion = completion;
	requestInfo.shouldRequestAllItems = grabAllItems;
	return [self queueRequestInfo:requestInfo];
}

@end
