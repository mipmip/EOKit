//
//  EORESTRequestInfo.m
//  EOSDK
//
//  Created by Andrew Kopanev on 1/10/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#import "EORESTRequestInfo.h"

@implementation EORESTRequestInfo

#pragma mark -

- (NSDictionary *)requestSpecificHeaders {
	return @{@"Content-Type" : @"application/json", @"Accept" : @"application/json"};
}

- (NSString *)resultURL {
	if (self.nextURL) {
		return self.nextURL.copy;
	} else {
		return [super resultURL];
	}
}

#pragma mark -

- (BOOL)isMeAPIMethod {
	return [self.apiName rangeOfString:@"current/Me"].location != NSNotFound;
}

@end
