//
//  PushNotifier.h
//  HomeSensor
//
//  Created by Michael Teeuw on 26-04-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushNotifier : NSObject

@property (strong, nonatomic) NSData * deviceToken;
+ (PushNotifier *)sharedInstance;
- (NSString *) deviceTokenAsString;

@end
