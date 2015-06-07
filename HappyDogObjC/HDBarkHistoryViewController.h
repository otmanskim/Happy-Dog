//
//  HDBarkHistoryViewController.h
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/19/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDHistoryProtocol.h"

@interface HDBarkHistoryViewController : UIViewController

@property (nonatomic, strong) NSArray *barkHistory;
@property (weak, nonatomic) id<HDHistoryProtocol> delegate;

@end
