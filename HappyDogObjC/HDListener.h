//
//  HDListener.h
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/14/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "HDListenerProtocol.h"

@interface HDListener : NSObject

@property (weak, nonatomic) id<HDListenerDelegate> delegate;
@property (nonatomic, assign) float micSensitivity;

- (void)beginRecordingAudio;
- (void)stopRecordingAudio;
- (BOOL)isRecording;

@end
