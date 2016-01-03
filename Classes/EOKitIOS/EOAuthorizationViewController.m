//
//  EOAuthorizationViewController.m
//  EOSDK
//
//  Created by Andrew Kopanev on 1/9/15.
//  Copyright (c) 2015 Moqod. All rights reserved.
//

#import "EOAuthorizationViewController.h"
#import "EOAPIProvider.h"

@interface EOAuthorizationViewController () <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView					*webView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem				*cancelBarButtonItem;
@property (nonatomic, strong) IBOutlet UINavigationBar				*navigationBar;
@property (nonatomic, strong) UIActivityIndicatorView				*activityIndicatorView;

@end

@implementation EOAuthorizationViewController

#pragma mark -

- (void)loadView {
    
    UIView *view = [[UIView alloc] init] ;

    self.view = view;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	
	_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	self.activityIndicatorView.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5);
}

#pragma mark - public

- (void)authorizeWithClientId:(NSString *)clientId authorizationURL:(NSString *)authorizationURL redirectURL:(NSString *)redirectURL {
	if (![self isViewLoaded]) {
		[self view];
	}
	self.redirectURL = redirectURL;
	NSString *urlString = [NSString stringWithFormat:@"%@?response_type=code&client_id=%@&redirect_uri=%@", authorizationURL, clientId, redirectURL];
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

#pragma mark - actions

- (void)cancelAction {
	[self.delegate eoAuthorizationViewController:self didFinishWithResponse:nil error:[NSError errorWithDomain:EOAPIProviderErrorDomain code:EOAPIProviderAuthorizationCancelled userInfo:nil]];
}

#pragma mark - helpers

- (NSDictionary *)dictionaryFromQuery:(NSString *)query {
	NSMutableDictionary *responseObject = [NSMutableDictionary dictionary];
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	for (NSString *pair in pairs) {
		NSArray *keyAndValue = [pair componentsSeparatedByString:@"="];
		if (2 == keyAndValue.count) {
			[responseObject setValue:[keyAndValue objectAtIndex:1] forKeyPath:[keyAndValue objectAtIndex:0]];
		}
	}
	return responseObject;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[self.view addSubview:self.activityIndicatorView];
	[self.activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self.activityIndicatorView stopAnimating];
	[self.activityIndicatorView removeFromSuperview];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ([request.URL.absoluteString rangeOfString:self.redirectURL].location == 0) {
		NSInteger queryIndex = self.redirectURL.length + 1;
		NSDictionary *responseObject = queryIndex <= request.URL.absoluteString.length ? [self dictionaryFromQuery:[request.URL.absoluteString substringFromIndex:queryIndex]] : nil;
		[self.delegate eoAuthorizationViewController:self didFinishWithResponse:responseObject error:nil];
		webView.delegate = nil;
		return NO;
	} else {
		return YES;
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	webView.delegate = nil;
	[self.delegate eoAuthorizationViewController:self didFinishWithResponse:nil error:error];
}

@end
