//
//  EORequestInfo.m
//  EOSDK
//
//  Created by Andrew Kopanev on 1/10/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#import "EORequestInfo.h"

@implementation EORequestInfo

- (instancetype)init {
	if (self = [super init]) {
		self.httpMethod = @"GET";
	}
	return self;
}

#pragma mark -

- (NSString *)resultURL {
	if (self.query.length) {
		return [NSString stringWithFormat:@"%@?%@", self.apiURL, self.query];
	} else {
		return self.apiURL.copy;
	}
}

@end
