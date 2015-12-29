//
//  EOAPIConstants.h
//  EOSDK
//
//  Created by Andrew Kopanev on 1/10/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#ifndef EOSDK_EOAPIConstants_h
#define EOSDK_EOAPIConstants_h

// typedefs
typedef void (^EOAPICompletion)(NSArray *results, NSError *error);

// errors
extern NSString *const EOAPIProviderErrorDomain;

/*
 * 
 NSError has this domain when error came from Exact Online API, like:
 {
	"error": {
		"code": "",
		"message": {
			"lang": "",
			"value": "Can't delete: Account 58 - Used in: Administrations"
		}
	}
 }
 Localized description contains error->message->value in this case
 */
extern NSString *const EOAPIErrorDomain;

typedef NS_ENUM(NSInteger, EOAPIProviderError) {
	EOAPIProviderAuthorizationCancelled = 1,		// User cancelled authorization
	EOAPIProviderAuthorizationBadParams	= 2
};


#endif
