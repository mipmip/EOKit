//
//  EOLoginViewController.m
//  EOKit
//
//  Created by Pim Snel on 29-12-15.
//  Copyright © 2015 Lingewoud BV. All rights reserved.
//

#import "EOLoginViewController.h"
#import <EOKit/EOKit.h>

#import <EOKit/EOAPIProvider.h>

@interface EOLoginViewController ()
    @property (nonatomic, strong) IBOutlet NSButton	*loginButton;
@end


@implementation EOLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    
    self.title = @"Exact Online";
    [_loginButton setTarget:self];
    [_loginButton setAction:@selector(loginAction:)];
}


- (IBAction)loginAction:(id)sender {


    NSString *clientId = @"b2314659-95c7-4bf6-8450-468db26abe8f";
    NSString *secret = @"AAtLBzurJ8B1";
    NSString *callbackURL = @"https://www.getpostman.com/oauth2/callback";
    
    NSLog(@"aha: %@, %@, %@", clientId, secret, callbackURL);
    
 
    [[EOAPIProvider providerWithClientId:clientId secret:secret] authorizeWithCallbackURL:callbackURL completion:^(NSError *error) {
        if (!error) {

            HelloWorld *objectOfYourCustomClass = [[HelloWorld alloc] init];
            objectOfYourCustomClass.name = @"Pim";
            [objectOfYourCustomClass sayHello];
            
            //[self.navigationController pushViewController:[EOGLAccountsTableViewController new] animated:YES];
        } else {
            NSLog(@"error == %@", error);
        }
    }];
 
}


@end
