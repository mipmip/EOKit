//
//  EORESTRequestInfo.h
//  EOSDK
//
//  Created by Andrew Kopanev on 1/10/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#import "EORequestInfo.h"

@interface EORESTRequestInfo : EORequestInfo

@property (nonatomic, strong) NSString		*apiName;
@property (nonatomic, assign) BOOL			shouldRequestAllItems;

@property (nonatomic, readonly) BOOL		isMeAPIMethod;

// paging support
@property (nonatomic, strong) NSString			*nextURL;
@property (nonatomic, strong) NSMutableArray	*results;

@end
