//
//  HDViewController.m
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/14/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import "HDViewController.h"
#import "HDSoundsCollector.h"

@interface HDViewController()

@property (weak, nonatomic) IBOutlet UIButton *toggleListeningButton;
@property (weak, nonatomic) IBOutlet UISlider *micSensitivitySlider;
@property (weak, nonatomic) IBOutlet UIButton *saveSensitivityButton;
@property (weak, nonatomic) IBOutlet UIButton *myRecordingsButton;

@end

#define kUserDefaultsSensitivityValueKey @"sensitivityValue"

@implementation HDViewController

- (void)viewDidLoad {
    self.listener = [[HDListener alloc] init];
    
    float savedSensitivityValue = [self retrieveSavedSensitivityValue];
    if(savedSensitivityValue >= 0) {
        [self.micSensitivitySlider setValue:savedSensitivityValue];
    }
    
    [self.micSensitivitySlider setValue:savedSensitivityValue >= 0 && savedSensitivityValue <= 1 ? savedSensitivityValue : .5];
    
    self.listener.micSensitivity = self.micSensitivitySlider.value;
    
    [self.micSensitivitySlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    
    [self disableSaveButton];
}

- (IBAction)toggleListeningButtonTapped:(id)sender {
    
    self.listener.micSensitivity = [self convertSliderValueToSensitivity];
    
    if(![self.listener isRecording]) {
        if([[HDSoundsCollector sharedInstance] allSounds].count) {
            [self.listener beginRecordingAudio];
            [self.toggleListeningButton setTitle:@"Stop Listening" forState:UIControlStateNormal];
            [self.myRecordingsButton setEnabled:NO];
        } else {
            [self displayNoSoundsAlert];
        }
    } else {
        [self.listener stopRecordingAudio];
        [self.toggleListeningButton setTitle:@"Start Listening" forState:UIControlStateNormal];
        [self.myRecordingsButton setEnabled:YES];
    }
}
- (IBAction)saveSensitivityButtonPressed:(id)sender {
    [self saveSensitivityValue];
}

- (void)saveSensitivityValue {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithFloat:self.micSensitivitySlider.value] forKey:kUserDefaultsSensitivityValueKey];
    [defaults synchronize];
    [self disableSaveButton];
}

- (float)retrieveSavedSensitivityValue {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:kUserDefaultsSensitivityValueKey] != nil ) {
        NSNumber *savedValue = [defaults objectForKey:kUserDefaultsSensitivityValueKey];
        return [savedValue floatValue];
    } else {
        return -1;
    }
}

- (float) convertSliderValueToSensitivity {
    return 1 - self.micSensitivitySlider.value;
}

- (void)sliderValueChanged {
    self.listener.micSensitivity = [self convertSliderValueToSensitivity];
    if(self.listener.micSensitivity != [self retrieveSavedSensitivityValue]) {
        [self enableSaveButton];
    }
}

- (void)disableSaveButton {
    [self.saveSensitivityButton setTitle:@"Saved" forState:UIControlStateNormal];
    [self.saveSensitivityButton setEnabled:NO];
    self.saveSensitivityButton.titleLabel.textColor = [UIColor grayColor];
}

- (void)enableSaveButton {
    [self.saveSensitivityButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveSensitivityButton setEnabled:YES];
    self.saveSensitivityButton.titleLabel.textColor = self.view.tintColor;
}

- (void)displayNoSoundsAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Sounds!" message:@"You do not have any sounds yet! Tap on 'My Sounds' to add some sounds." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *goToMyRecordingsAction = [UIAlertAction actionWithTitle:@"Go to My Sounds" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self performSegueWithIdentifier:@"myRecordingsSegue" sender:self];
    }];
    
    [alertController addAction:goToMyRecordingsAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
