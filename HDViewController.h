//
//  HDViewController.h
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/14/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDListener.h"
#import "HDListenerProtocol.h"



@interface HDViewController : UIViewController <HDListenerDelegate>

@property (nonatomic, strong) HDListener *listener;

@end
