//
//  Api.m
//  HomeSensor
//
//  Created by Michael Teeuw on 26-04-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

#import "Api.h"

@implementation Api

+ (void)performRequestWithUri:(NSString *)requestUri params:(NSDictionary *)params completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock
{
    
    // Generate the URL
    NSString *requestUrl = [NSString stringWithFormat:@"http://192.168.0.123:8081/api/%@", requestUri];
    
    // Create the connection
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    [request setHTTPMethod:@"GET"];
    
    // Make an NSOperationQueue
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setName:@"nl.xonaymedia.homesensor.api"];
    
    // Send an asyncronous request on the queue
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // If there was an error getting the data
        if (error) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                completionBlock(nil, error);
            });
            return;
        }
        
        // Decode the data
        NSError *jsonError;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        // If there was an error decoding the JSON
        if (jsonError) {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
            });
            return;
        }
        
        // All looks fine, lets call the completion block with the response data
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            completionBlock(responseDict, nil);
        });
    }];
}

@end
