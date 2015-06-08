//
//  AppDelegate.m
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/14/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import "AppDelegate.h"
#import "HDSoundsCollector.h"
#import "HDSoundRecording.h"
#import "HDConstants.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse setApplicationId:@"4ZdCm6J4pCdMAdtgxZMv9PFT9xSfBtqRkOq94FVj"
                  clientKey:@"0Xn3swuVfCFISAkTlYCmWKdWEM3HB507FVMVMDUG"];
    
    [self populateSoundsArray];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation addUniqueObject:@"Eros_Bark" forKey:@"channels"];
    [currentInstallation saveInBackground];
    
    [self updatePushNotificationListenerChannel];
}

- (void)stopListeningForCurrentChannel {
    NSString *channel = [self channelName];

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObject:channel forKey:@"channels"];
    [currentInstallation saveInBackground];
}

/**
 Either starts or stops listening on the channel with the current saved dog name, depending on the "isListeningDevice" value
 */
- (void)updatePushNotificationListenerChannel {
    
    NSString *channel = [self channelName];
    
    if(channel.length == 0) {
        channel = @"Default_Channel";
    }
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kNSUserDefaultsIsListeningDeviceKey]) {
        //if NOT a listener, add channel so it can get push notifications from the listener
        [currentInstallation addUniqueObject:channel forKey:@"channels"];
    } else {
        //else remove it so we aren't listening
        [currentInstallation removeObject:channel forKey:@"channels"];
    }
    
    [currentInstallation saveInBackground];
}

- (void)sendBarkPushNotification {
    NSString *channelString = [self channelName];
    NSString *messageString = [NSString stringWithFormat:@"A bark was just detected from %@!", [[NSUserDefaults standardUserDefaults] objectForKey:kNSUserDefaultsDogNameKey]];
    
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:channelString];
    [push setMessage:messageString];
    [push sendPushInBackground];
}

- (NSString *)channelName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *dogName = [defaults objectForKey:kNSUserDefaultsDogNameKey];
    NSString *email = [defaults objectForKey:kNSUserDefaultsEmailKey];
    NSString *nameFromEmail = @"";
    
    if(email.length) {
        nameFromEmail = [email substringToIndex:[email rangeOfString:@"@"].location];
    }
    
    if(dogName.length == 0) {
        dogName = @"Default_Name";
    }
    
    if(nameFromEmail.length == 0) {
        nameFromEmail = @"Default_Email";
    }
    
    NSString *channelName = [NSString stringWithFormat:@"%@_%@_Bark",nameFromEmail,dogName];
    
    return channelName;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)populateSoundsArray {
    HDSoundsCollector *collector = [HDSoundsCollector sharedInstance];
    [collector performInitialSoundFetchFromUserDefaults];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
