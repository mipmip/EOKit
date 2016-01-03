//
//  EOAuthorizationViewController.h
//  EOSDK
//
//  Created by Andrew Kopanev on 1/9/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EOAuthorizationViewController;
@protocol EOAuthorizationViewControllerDelegate <NSObject>

- (void)eoAuthorizationViewController:(EOAuthorizationViewController *)viewController didFinishWithResponse:(NSDictionary *)response error:(NSError *)error;

@end

@interface EOAuthorizationViewController : UIViewController

@property (nonatomic, strong) NSString *redirectURL;
@property (nonatomic, assign) id <EOAuthorizationViewControllerDelegate> delegate;

- (void)authorizeWithClientId:(NSString *)clientId authorizationURL:(NSString *)authorizationURL redirectURL:(NSString *)redirectURL;

@end
