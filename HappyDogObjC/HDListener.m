//
//  HDListener.m
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/14/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import "HDListener.h"
#import "HDSoundsCollector.h"
#import "HDConstants.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface HDListener() <AVAudioPlayerDelegate>

@property (nonatomic, strong) NSTimer *checkSoundLevelsTimer;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioSession *audioSession;

@property (nonatomic, assign) double lowPassResults;
@property (nonatomic, strong) NSArray *soundEffects;

@end

@implementation HDListener

- (instancetype) init {
    self = [super init];
    if (self) {
        self.soundEffects = [[HDSoundsCollector sharedInstance] allSounds];
    }
    
    return self;
}

- (void)beginRecordingAudio {
    [self prepareAudioRecorder];
    [self.audioRecorder record];
}

- (void)stopRecordingAudio {
    [self.audioRecorder stop];
    self.audioRecorder = nil;
    [self.checkSoundLevelsTimer invalidate];
    self.checkSoundLevelsTimer = nil;
}

- (void)prepareAudioRecorder {
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    self.audioSession = [AVAudioSession sharedInstance];
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (self.audioRecorder) {
        [self.audioRecorder prepareToRecord];
        self.audioRecorder.meteringEnabled = YES;
        self.checkSoundLevelsTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(checkSoundLevels) userInfo: nil repeats: YES];
    } else {
        NSLog(@"%@", [error description]);
    }

}

- (void)checkSoundLevels {
    [self.audioRecorder updateMeters];
    
    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (0.05 * [self.audioRecorder peakPowerForChannel:0]));
    self.lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * self.lowPassResults;
    
    if(self.lowPassResults > self.micSensitivity) {
        self.lowPassResults = 0;
        [self.delegate barkDetected];
        NSLog(@"Barking Detected");
        [self stopRecordingAudio];
        [self playSound];
        [self sendPushNotification];
    }
}

- (void)sendPushNotification {
    //if this device is a listener, send push notification
    if([[NSUserDefaults standardUserDefaults] boolForKey:kNSUserDefaultsIsListeningDeviceKey]) {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) sendBarkPushNotification];
    }
}

- (void)playSound {
    [self.delegate soundStartedPlaying];
    NSError *error;

    [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    [self.audioSession setActive:YES error:&error];
    
    HDSoundRecording *soundRecording = self.soundEffects[[self randomIndexIntoSoundEffectsArray]];
    NSURL *audioFileLocationURL = [[NSBundle mainBundle] URLForResource:soundRecording.recordingName withExtension:soundRecording.fileType];


    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               [NSString stringWithFormat:@"%@.%@", soundRecording.recordingName, soundRecording.fileType],
                               nil];
    
    NSURL *recordedAudioURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    
    self.audioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:recordedAudioURL error:&error];

    if(!self.audioPlayer) {
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileLocationURL error:&error];
    }
    
    [self.audioPlayer setNumberOfLoops:0];
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.delegate soundFinishedPlaying];
    [self stopAudioAndResumeRecording];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self.delegate soundFinishedPlaying];
    [self stopAudioAndResumeRecording];
}

- (void)stopAudioAndResumeRecording {
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    [self beginRecordingAudio];
}

- (NSInteger) randomIndexIntoSoundEffectsArray {
    return arc4random() % self.soundEffects.count;
}

- (BOOL)isRecording {
    return self.audioRecorder.isRecording;
}


@end
