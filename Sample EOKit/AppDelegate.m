//
//  AppDelegate.m
//  Sample EOKit
//
//  Created by Pim Snel on 29-12-15.
//  Copyright © 2015 Lingewoud BV. All rights reserved.
//

#import "AppDelegate.h"
#import <EOKit/EOKit.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    

    HelloWorld *objectOfYourCustomClass = [[HelloWorld alloc] init];
    objectOfYourCustomClass.name = @"Pim";
    [objectOfYourCustomClass sayHello];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
