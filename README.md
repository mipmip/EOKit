# EOKit

[![CI Status](http://img.shields.io/travis/Pim Snel/EOKit.svg?style=flat)](https://travis-ci.org/Pim Snel/EOKit)
[![Version](https://img.shields.io/cocoapods/v/EOKit.svg?style=flat)](http://cocoapods.org/pods/EOKit)
[![License](https://img.shields.io/cocoapods/l/EOKit.svg?style=flat)](http://cocoapods.org/pods/EOKit)
[![Platform](https://img.shields.io/cocoapods/p/EOKit.svg?style=flat)](http://cocoapods.org/pods/EOKit)

EOKit is an Exact Online client library for iOS and OSX. All Apple
Platfoms will be supported in the future.

EOKit is a fork of https://github.com/moqod/Exact-Online-iOS-SDK.
We started this rewrite to support OSX and IOS and to make this project more usable by
adding a pod file.

# About Exact Online
[Exact Online](http://www.exactonline.com/) is the business software that automates your manufacturing, logistics and CRM in the cloud.
<br/> This Objective-C SDK provides easy access to Exact Online API for iOS apps. More information about [Exact Online](http://www.exactonline.com/), [API Documentation](https://developers.exactonline.com/).

# Features
- Authorization & Token refreshing
- REST API access
- iOS and Mac OS X support
- Cocoapod specfile

## Installation

EOKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "EOKit"
```

# Sample Applications

Please check the sample applications for real life usage.

- [EOKit iOS Sample App](https://github.com/Lingewoud/EOKit-iOS-Sample-App)
- [EOKit OSX Sample App](https://github.com/Lingewoud/EOKit-OSX-Sample-App)

# Sample
Authorization
```objc
	[[EOAPIProvider providerWithClientId:clientId secret:secret] authorizeWithCallbackURL:callbackURL completion:^(NSError *error) {
		if (!error) {
			// ...
		} else {
		  // handle error
			NSLog(@"error == %@", error);
		}
	}];
```

Request an API
```objc
	[[EOAPIProvider anyProvider] restGetAPI:@"current/Me" completion:^(NSArray *results, NSError *error) {
		if (!error) {
			[self requestAccounts];
		} else {
			[self handleError:error];
		}
	}];
```

# Notes

## OData

Use `odataParams` parameter in methods, see sample for more details. We don't see any reason for real OData implementation now, `NSDictionary` is enough.


## Division
Almost all API methods require `division` parameter. `EOAPIProvider` has property `currentDivision`, this property is setup automatically after requesting `current/Me` API method, also it is possible to setup any value you want (if you need to support multiple accounts).


## Paging
Exact Online API Documentaion: *All CRUD services have a limition of maximum 60 records within one API request. The READ services will soon have a similar limitation.*<br />
If you need all items with one line of code then you could use `grabAllItems` parameter in method:

``` objc
- (NSOperation *)restGetAPI:(NSString *)apiName division:(NSString *)division odataParams:(NSDictionary *)odataParams grabAllItems:(BOOL)grabAllItems completion:(EOAPICompletion)completion;
```

## License

EOKit is available under the MIT license. See the LICENSE file for more info.

Development sponsored by [Lingewoud BV](http://lingewoud.com)
