//
//  HDListener.m
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/14/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import "HDListener.h"

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
        NSURL *audioFile1LocationURL = [[NSBundle mainBundle] URLForResource:@"raygun-01" withExtension:@"wav"];
        NSURL *audioFile2LocationURL = [[NSBundle mainBundle] URLForResource:@"pencil_scribble_out_on_paper" withExtension:@"mp3"];
        NSURL *audioFile3LocationURL = [[NSBundle mainBundle] URLForResource:@"small_address_book_page_turn_twice" withExtension:@"mp3"];

        self.soundEffects = [NSArray arrayWithObjects:audioFile1LocationURL, audioFile2LocationURL, audioFile3LocationURL, nil];
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
    
    NSLog(@"Average input: %f Peak input: %f", [self.audioRecorder averagePowerForChannel:0], [self.audioRecorder peakPowerForChannel:0]);
    
    NSLog(@"Low Pass Results: %f", self.lowPassResults);
    
    if(self.lowPassResults > self.micSensitivity) {
        NSLog(@"Barking Detected");
        [self playSound];
    }
}

- (void)playSound {
    NSError *error;

    [self stopRecordingAudio];
    [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    [self.audioSession setActive:YES error:&error];
    
    NSURL *audioFileLocationURL = self.soundEffects[[self randomIndexIntoSoundEffectsArray]];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileLocationURL error:&error];
    [self.audioPlayer setNumberOfLoops:0];
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stopAudioAndResumeRecording];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
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
