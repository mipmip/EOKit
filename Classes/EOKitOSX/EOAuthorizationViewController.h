//
//  EOAuthorizationViewController.h
//  EOKit
//
//  Created by Pim Snel on 29-12-15.
//  Copyright © 2015 Lingewoud BV. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EOAuthorizationViewController;
@protocol EOAuthorizationViewControllerDelegate <NSObject>

- (void)eoAuthorizationViewController:(EOAuthorizationViewController *)viewController didFinishWithResponse:(NSString *)response error:(NSError *)error;

@end

@interface EOAuthorizationViewController : NSViewController

@property (nonatomic, strong) NSString *redirectURL;

@property (nonatomic, assign) id <EOAuthorizationViewControllerDelegate> delegate;

- (void)authorizeWithClientId:(NSString *)clientId authorizationURL:(NSString *)authorizationURL redirectURL:(NSString *)redirectURL;
@end
