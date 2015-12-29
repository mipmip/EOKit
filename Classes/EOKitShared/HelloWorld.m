//
//  HelloWorld.m
//  EOKit
//
//  Created by Pim Snel on 29-12-15.
//  Copyright © 2015 Lingewoud BV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HelloWorld.h"

@implementation HelloWorld



- (void)sayHello {
    NSLog(@"Hello hello %@", self.name);
    
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * versionBuildString = [NSString stringWithFormat:@"Version: %@ (%@)", appVersionString, appBuildString];
    NSLog(@"This is EOKit: %@", versionBuildString);

}
@end