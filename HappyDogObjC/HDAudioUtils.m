//
//  HDAudioUitlities.m
//  HappyDogObjC
//
//  Created by Michael Otmanski on 5/25/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import "HDAudioUtils.h"
#import "HDSoundsCollector.h"
#import "HDConstants.h"
#import <AVFoundation/AVFoundation.h>

@interface HDAudioUtils() <AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@property(strong, nonatomic)AVAudioSession *audioSession;
@property(strong, nonatomic)AVAudioPlayer *audioPlayer;
@property(strong, nonatomic)AVAudioRecorder *audioRecorder;

@property (strong, nonatomic) NSTimer *checkSoundLevelsTimer;
@property (assign, nonatomic) double lowPassResults;

@property (assign, nonatomic) BOOL playingBecauseOfBark;

@end

@implementation HDAudioUtils

+ (HDAudioUtils *)sharedInstance {
    static dispatch_once_t predicate = 0;
    static HDAudioUtils *sharedObject = nil;
    
    dispatch_once(&predicate, ^{
        sharedObject = [[HDAudioUtils alloc] init];
        sharedObject.audioSession = [AVAudioSession sharedInstance];
        sharedObject.audioPlayer = [[AVAudioPlayer alloc] init];
        sharedObject.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:@"/dev/null"] settings:nil error:nil];
    });
    
    return sharedObject;
}

- (void)playRandomSavedSound {
    HDAudioUtils *utils = [HDAudioUtils sharedInstance];

    [utils.delegate soundStartedPlaying];
    utils.playingBecauseOfBark = YES;
    [utils stopAllCurrentActivity];
    
    [utils.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [utils.audioSession setActive:YES error:nil];
    
    NSArray *sounds = [[HDSoundsCollector sharedInstance] allSounds];
    HDSoundRecording *selectedSound = sounds[arc4random() % sounds.count];
    
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [self documentsPath],
                               [NSString stringWithFormat:@"%@.%@", selectedSound.recordingName, selectedSound.fileType],
                               nil];
    
    NSURL *audioFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    
    utils.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:nil];
    
    [utils.audioPlayer setNumberOfLoops:0];
    utils.audioPlayer.delegate = self;
    [utils.audioPlayer prepareToPlay];
    [utils.audioPlayer play];
}

- (void)playSound:(HDSoundRecording *)sound {
    HDAudioUtils *utils = [HDAudioUtils sharedInstance];

    [utils.delegate soundStartedPlaying];
    utils.playingBecauseOfBark = NO;
    [utils stopAllCurrentActivity];
    
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [self documentsPath],
                               [NSString stringWithFormat:@"%@.%@", sound.recordingName, sound.fileType],
                               nil];
    
    NSURL *audioFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    
    utils.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:nil];
    
    [utils.audioPlayer setNumberOfLoops:0];
    utils.audioPlayer.delegate = self;
    [utils.audioPlayer prepareToPlay];
    [utils.audioPlayer play];

}


- (void)startRecordingWithToSaveURL:(NSURL *)toSaveURL {
    HDAudioUtils *utils = [HDAudioUtils sharedInstance];

    [utils stopAllCurrentActivity];
    
    [utils.audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [utils.audioSession setActive:YES error:nil];

    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    utils.audioRecorder = [[AVAudioRecorder alloc] initWithURL:toSaveURL settings:recordSetting error:nil];
    [utils.audioRecorder prepareToRecord];
    
    [utils.audioRecorder record];
}

- (void)startRecordingForMetering {
    HDAudioUtils *utils = [HDAudioUtils sharedInstance];

    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    
    utils.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:nil];
    
    [utils.audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    [utils.audioRecorder prepareToRecord];
    utils.audioRecorder.meteringEnabled = YES;

    utils.checkSoundLevelsTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: utils selector: @selector(checkSoundLevels) userInfo: nil repeats: YES];
    
}

- (void)checkSoundLevels {
    HDAudioUtils *utils = [HDAudioUtils sharedInstance];

    [utils.audioRecorder updateMeters];
    
    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (0.05 * [utils.audioRecorder peakPowerForChannel:0]));
    utils.lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * self.lowPassResults;
    
    if(utils.lowPassResults > utils.micSensitivityLevel) {
        //bark detected
        utils.lowPassResults = 0;
        [utils.delegate barkDetected];
    }
}

- (BOOL)isRecording {
    HDAudioUtils *utils = [HDAudioUtils sharedInstance];
    return utils.audioRecorder && utils.audioRecorder.isRecording;
}

- (void)stopRecording {
    [self stopAllCurrentActivity];
}

- (void)stopAllCurrentActivity {
    HDAudioUtils *utils = [HDAudioUtils sharedInstance];

    if(utils.audioRecorder.isRecording) {
        [utils.audioRecorder stop];
    }
    
    if(utils.audioPlayer.isPlaying) {
        [utils.audioPlayer stop];
    }
}

- (NSString*) documentsPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    HDAudioUtils *utils = [HDAudioUtils sharedInstance];

    [utils.delegate soundFinishedPlaying];
}


@end
