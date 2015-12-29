//
//  EOJSONResponseSerializer.m
//  EOSDK
//
//  Created by Andrew Kopanev on 1/10/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#import "EOJSONResponseSerializer.h"
#import "EOAPIConstants.h"

@implementation EOJSONResponseSerializer

- (instancetype)init {
	if (self = [super init]) {
		self.removesKeysWithNullValues = YES;
	}
	return self;
}

#pragma mark -

- (BOOL)validateResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError * __autoreleasing *)error {
	BOOL isResponseValid = [super validateResponse:response data:data error:error];
	if (!isResponseValid && [@"application/json" isEqualToString:response.allHeaderFields[@"Content-Type"]]) {
		// looks like we got Exact Online error
		// let's try to sort it out
		NSError *parsingError = nil;
		NSDictionary *errorDictionary = [NSJSONSerialization JSONObjectWithData:data options:self.readingOptions error:&parsingError];
		if ([errorDictionary isKindOfClass:[NSDictionary class]] && errorDictionary[@"error"] != nil) {
			NSString *localizedDescription = errorDictionary[@"error"][@"message"][@"value"] ? errorDictionary[@"error"][@"message"][@"value"] : errorDictionary.descriptionInStringsFileFormat;
			*error = [NSError errorWithDomain:EOAPIErrorDomain code:response.statusCode userInfo:@{ NSLocalizedDescriptionKey : localizedDescription }];
		}
	}
	return isResponseValid;
}

@end
