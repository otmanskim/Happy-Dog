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
@property (weak, nonatomic) IBOutlet UIButton *playRecordingButton;

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioSession *audioSession;
@property (nonatomic, strong) NSString *fileDestinationString;
@property (nonatomic, strong) NSString *createdSoundFilename;


@end

@implementation HDCreateSoundViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationItems];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    [self.view addGestureRecognizer:tapRecognizer];
    // Do any additional setup after loading the view.
}

- (void) setupNavigationItems{
    self.navigationItem.title = @"Create New Sound";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (IBAction)recordButtonTapped:(id)sender {
    
    NSLog(@"AudioRecorder.isRecording  = %d", [self.audioRecorder isRecording]);
    
    if(![self newSoundNamePassesCriteria]) {
        //only allow recording if we already have a valid name
        [self showNeedsNameAlert];
    } else {
        if([self.audioRecorder isRecording]) {
            [self stopRecording];
            [self.recordingNameTextField setUserInteractionEnabled:YES];
            [self.recordButton setBackgroundImage:[UIImage imageNamed:@"microphone"] forState:UIControlStateNormal];
        } else {
            [self startRecording];
            [self.recordingNameTextField setUserInteractionEnabled:NO];
            [self.recordButton setBackgroundImage:[UIImage imageNamed:@"microphone-red"] forState:UIControlStateNormal];
        }
    }
}

- (void)startRecording {
    self.audioSession = [AVAudioSession sharedInstance];
    [self.audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [self.audioSession setActive:YES error:nil];

    
    NSError *error;
    
    self.createdSoundFilename = [self newRecordingNameFromTextInput];
    
    // sets the path for audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               [NSString stringWithFormat:@"%@.m4a", self.createdSoundFilename],
                               nil];
    
    NSURL *recordedAudioURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // settings for the recorder
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:recordedAudioURL settings:recordSetting error:&error];
    [self.audioRecorder prepareToRecord];

    
    [self.audioRecorder record];
}

//replaces any spaces with underscores
- (NSString *)newRecordingNameFromTextInput {
    return [self.recordingNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"_"];
}

-(void) playRecord
{
    if(self.createdSoundFilename) {
        self.audioSession = [AVAudioSession sharedInstance];
        [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [self.audioSession setActive:YES error:nil];
        
        // sets the path for audio file
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [self documentsPath],
                                   [NSString stringWithFormat:@"%@.m4a", self.createdSoundFilename],
                                   nil];
        
        NSURL *recordedAudioURL = [NSURL fileURLWithPathComponents:pathComponents];
        
        NSError *error;

        self.audioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:recordedAudioURL error:&error];
        
        if(error) {
            [self showNoRecordingAlert];
        } else {
            [self.audioPlayer play];
        }
    } else {
        [self showNoRecordingAlert];
    }
}

- (NSString*) documentsPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)stopRecording {
    [self.audioRecorder stop];
}

- (void)doneButtonPressed {
    if([self newSoundNamePassesCriteria] && [self newRecordingExists]) {
        [self createNewSoundRecordingObject];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self showInvalidAlert];
    }
}

- (void)createNewSoundRecordingObject {
    HDSoundRecording *newRecording = [[HDSoundRecording alloc] initWithName:self.createdSoundFilename andFileType:@"m4a"];
    [[HDSoundsCollector sharedInstance] addSound:newRecording];
}

- (BOOL)newRecordingExists {
    BOOL exists = NO;
    
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [self documentsPath],
                               [NSString stringWithFormat:@"%@.m4a", self.createdSoundFilename],
                               nil];
    
    NSURL *recordedAudioURL = [NSURL fileURLWithPathComponents:pathComponents];
    NSError *error;
    AVAudioPlayer *tempPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:recordedAudioURL error:&error];
    
    exists = tempPlayer != nil;
    
    return exists;
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
- (IBAction)playRecordingButtonTapped:(id)sender {
    [self playRecord];
}

- (void)viewTapped {
    [self.recordingNameTextField resignFirstResponder];
}

#pragma mark - Alert View Methods
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

- (void)showNeedsNameAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Need Valid Title" message:@"You must enter a valid name for your new sound before recording." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showNoRecordingAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Recording Yet" message:@"There is no recorded sound yet." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
