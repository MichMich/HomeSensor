//
//  Api.h
//  HomeSensor
//
//  Created by Michael Teeuw on 26-04-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Api : NSObject

+ (void)performRequestWithUri:(NSString *)requestUri params:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;

@end
