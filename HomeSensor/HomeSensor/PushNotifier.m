//
//  PushNotifier.m
//  HomeSensor
//
//  Created by Michael Teeuw on 26-04-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

#import "PushNotifier.h"

@interface PushNotifier ()



@end

@implementation PushNotifier

+ (PushNotifier *)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}


- (NSString *) deviceTokenAsString
{
    return [[[self.deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@end
