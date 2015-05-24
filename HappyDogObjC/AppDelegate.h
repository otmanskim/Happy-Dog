//
//  AppDelegate.h
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/14/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)stopListeningForCurrentChannel;
- (void)updatePushNotificationListenerChannel;
- (void)sendBarkPushNotification;

@end

