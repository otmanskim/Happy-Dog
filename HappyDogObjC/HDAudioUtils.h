//
//  HDAudioUitlities.h
//  HappyDogObjC
//
//  Created by Michael Otmanski on 5/25/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import "HDSoundRecording.h"
#import "HDListenerProtocol.h"
#import <Foundation/Foundation.h>


@interface HDAudioUtils : NSObject

@property(weak,nonatomic) id<HDListenerDelegate> delegate;
@property(assign, nonatomic)float micSensitivityLevel;

+ (HDAudioUtils *)sharedInstance;

- (void)startRecordingWithToSaveURL:(NSURL *)toSaveURL;

- (void)startRecordingForMetering;

- (void)playSound:(HDSoundRecording *)sound;

- (void)playRandomSavedSound;

- (void)stopRecording;

- (BOOL)isRecording;

@end
