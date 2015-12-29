//
//  EORequestInfo.h
//  EOSDK
//
//  Created by Andrew Kopanev on 1/10/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOAPIConstants.h"

@interface EORequestInfo : NSObject

// request information
@property (nonatomic, strong) NSString			*apiURL;
@property (nonatomic, strong) NSString			*httpMethod;
@property (nonatomic, strong) NSDictionary		*httpHeaders;
@property (nonatomic, strong) NSData			*body;
@property (nonatomic, strong) NSString			*query;

@property (nonatomic, readonly) NSDictionary	*requestSpecificHeaders;

@property (nonatomic, copy) EOAPICompletion		completion;

// returns constructed URL based on request information
@property (nonatomic, readonly) NSString		*resultURL;

@end
