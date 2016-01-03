//
//  EOAuthorizationViewControllerOSX.m
//  EOKit
//
//  Created by Pim Snel on 29-12-15.
//  Copyright © 2015 Lingewoud BV. All rights reserved.
//


#import "EOAuthorizationViewController.h"
#import <WebKit/WebKit.h>

@interface EOAuthorizationViewController () <WebFrameLoadDelegate>

@property (nonatomic, strong) IBOutlet WebView *myWebView;

@end

@implementation EOAuthorizationViewController

- (void)loadView {
    NSLog(@"view: load");

    NSRect frame = NSMakeRect(0, 0, 400, 400);

    _myWebView = [[WebView alloc] initWithFrame:frame
                                              frameName:@"Test Frame"
                                              groupName:nil];
    self.view = _myWebView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

//    [[_myWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.github.com"]]];
    [_myWebView setFrameLoadDelegate:self];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
}

- (void)authorizeWithClientId:(NSString *)clientId authorizationURL:(NSString *)authorizationURL redirectURL:(NSString *)redirectURL {
    if (![self isViewLoaded]) {
        [self view];
    }
    self.redirectURL = redirectURL;
    NSString *urlString = [NSString stringWithFormat:@"%@?response_type=code&client_id=%@&redirect_uri=%@", authorizationURL, clientId, redirectURL];
    [[_myWebView mainFrame ] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)webView:(WebView *)sender didReceiveServerRedirectForProvisionalLoadForFrame:(WebFrame *)frame {
    NSString *currentRequest = [_myWebView mainFrameURL];
    
    NSArray *url_items = [currentRequest componentsSeparatedByString:@"code="];
    [self.delegate eoAuthorizationViewController:self didFinishWithResponse:[url_items lastObject] error:nil];
}

@end
