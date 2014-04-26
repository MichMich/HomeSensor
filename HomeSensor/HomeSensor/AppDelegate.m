//
//  AppDelegate.m
//  HomeSensor
//
//  Created by Michael Teeuw on 25-04-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

#import "AppDelegate.h"
#import "PushNotifier.h"

#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];

    
    // Override point for customization after application launch.
    return YES;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [PushNotifier sharedInstance].deviceToken = deviceToken;
    
    NSLog(@"Device Token: %@",[[PushNotifier sharedInstance] deviceTokenAsString]);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Fail to register for remote notifications: %@", [error localizedDescription]);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%@",userInfo);

    NSString *sound = [userInfo valueForKeyPath:@"aps.sound"];
    
    NSURL *soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], sound]];
	
    NSLog(@"%@", soundURL);
    
	NSError *error;
	self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
	[self.audioPlayer play];
    
    
    
    NSString *message = [userInfo valueForKeyPath:@"aps.alert"];
    
    [[[UIAlertView alloc] initWithTitle: message message:nil delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

    

    
    
    /*
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:nil ofType:@"aiff"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
     */

    //[player play];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
