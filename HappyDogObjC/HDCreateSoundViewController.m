//
//  HDCreateSoundViewController.m
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/14/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import "HDCreateSoundViewController.h"
#import "HDSoundsCollector.h"
#import <AVFoundation/AVFoundation.h>

@interface HDCreateSoundViewController ()
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UITextField *recordingNameTextField;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioSession *audioSession;

@end

@implementation HDCreateSoundViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationItems];
    // Do any additional setup after loading the view.
}

- (void) setupNavigationItems{
    self.navigationItem.title = @"Create New Sound";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (IBAction)recordButtonTapped:(id)sender {
    if(self.audioRecorder.isRecording) {
        [self stopRecording];
        [self.recordButton setBackgroundImage:[UIImage imageNamed:@"microphone"] forState:UIControlStateNormal];
    } else {
        [self startRecording];
        [self.recordButton setBackgroundImage:[UIImage imageNamed:@"microphone-red"] forState:UIControlStateNormal];
    }
}

- (void)startRecording {
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
    } else {
        NSLog(@"%@", [error description]);
    }
    
    [self.audioRecorder record];
}

- (void)stopRecording {
    [self.audioRecorder stop];
    self.audioRecorder = nil;
}

- (void)doneButtonPressed {
    if([self newSoundNamePassesCriteria]) {
        //replace any spaces in name with "-"
        //create new HDSoundRecording with new name and whatever the default file type for these saved files is
        //add this sound recording to the list in HDSoundsCollector
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self showInvalidAlert];
    }
}

- (BOOL)newSoundNamePassesCriteria {
    NSString *name = self.recordingNameTextField.text;
    BOOL passed = NO;
    
    //will also need to check for valid audio file
    if(name.length > 3 && ![[HDSoundsCollector sharedInstance] soundWithNameExists:name] &&
       [self stringHasOnlyAlphaneumericCharacters:name]) {
        passed = YES;
    }
    
    return passed;
}

- (BOOL)stringHasOnlyAlphaneumericCharacters:(NSString *)string  {
    NSMutableCharacterSet *allowedCharacters = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
    [allowedCharacters addCharactersInString:@" "];
    
    BOOL valid = [[string stringByTrimmingCharactersInSet:allowedCharacters] isEqualToString:@""];
    return valid;
}

- (void)showInvalidAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid Sound" message:@"New sounds must have a recording, and a title with: at least 4 characters, no numbers or special characters, and must not already exist in the app." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}



@end
