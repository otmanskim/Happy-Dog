//
//  HDViewController.m
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/14/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import "HDViewController.h"
#import "HDSoundsCollector.h"
#import "HDBarkHistoryViewController.h"
#import "HDHistoryProtocol.h"
#import "HDSettingsViewController.h"
#import "HDConstants.h"
#import "HDAudioUtils.h"

#define kSettingsPopoverHeight 200

@interface HDViewController() <HDHistoryProtocol, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *toggleListeningButton;
@property (weak, nonatomic) IBOutlet UISlider *micSensitivitySlider;
@property (weak, nonatomic) IBOutlet UIButton *saveSensitivityButton;
@property (weak, nonatomic) IBOutlet UIButton *myRecordingsButton;
@property (weak, nonatomic) IBOutlet UILabel *barkCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *barkHistoryButton;
@property (weak, nonatomic) IBOutlet UILabel *sensitivityLabel;

@property (strong, nonatomic) NSMutableArray *allBarks;
@property (assign, nonatomic) NSInteger todaysBarkCount;

@end

@implementation HDViewController

- (void)viewDidLoad {
    [self setupUI];
    self.allBarks = [[NSMutableArray alloc] init];
    self.todaysBarkCount = 0;
    [self fetchOldBarksFromUserDefaults];
    self.listener = [[HDListener alloc] init];
    self.listener.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    
    float savedSensitivityValue = [self retrieveSavedSensitivityValue];
    if(savedSensitivityValue >= 0) {
        [self.micSensitivitySlider setValue:savedSensitivityValue];
    }
    
    [self.micSensitivitySlider setValue:savedSensitivityValue >= 0 && savedSensitivityValue <= 1 ? savedSensitivityValue : .5];
    
    self.listener.micSensitivity = self.micSensitivitySlider.value;
    
    [self.micSensitivitySlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    
    [self disableSaveButton];
}

- (void)setupUI {
    self.navigationController.navigationBar.backgroundColor = [UIColor cyanColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor brownColor]}];

    self.toggleListeningButton.backgroundColor = [UIColor cyanColor];
    [self.toggleListeningButton setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    
    self.view.backgroundColor = [UIColor brownColor];
    [self.barkCountLabel setTextColor:[UIColor whiteColor]];
    [self.sensitivityLabel setTextColor:[UIColor whiteColor]];
    [self.barkHistoryButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.myRecordingsButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    
    [self.saveSensitivityButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    self.micSensitivitySlider.tintColor = [UIColor cyanColor];
}

- (void)fetchOldBarksFromUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.allBarks = [[defaults objectForKey:kUserDefaultsBarksHistoryKey] mutableCopy];
    if(!self.allBarks) {
        self.allBarks = [[NSMutableArray alloc] init];
    }
    
    [self checkIfOldBarksAreTodays];
    
}

- (void)checkIfOldBarksAreTodays {
    self.todaysBarkCount = 0;
    for(NSDate *date in self.allBarks) {
        if([[NSCalendar currentCalendar] isDateInToday:date]) {
            self.todaysBarkCount++;
        }
    }
    
    self.barkCountLabel.text = [NSString stringWithFormat:@"%lu today", (long)self.todaysBarkCount];
}

- (IBAction)toggleListeningButtonTapped:(id)sender {
    
//    self.listener.micSensitivity = [self convertSliderValueToSensitivity];
    [HDAudioUtils sharedInstance].micSensitivityLevel = [self convertSliderValueToSensitivity];
    
    if(![HDAudioUtils sharedInstance].isRecording) {
        if([[HDSoundsCollector sharedInstance] allSounds].count) {
//            [self.listener beginRecordingAudio];
            [HDAudioUtils sharedInstance].delegate = self;
            [[HDAudioUtils sharedInstance] startRecordingForMetering];
            
            [self.toggleListeningButton setTitle:@"Stop Listening" forState:UIControlStateNormal];
            [self.myRecordingsButton setEnabled:NO];
            [self.barkHistoryButton setEnabled:NO];
        } else {
            [self displayNoSoundsAlert];
        }
    } else {
//        [self.listener stopRecordingAudio];
        [[HDAudioUtils sharedInstance] stopRecording];
        
         
        [self.toggleListeningButton setTitle:@"Start Listening" forState:UIControlStateNormal];
        [self.myRecordingsButton setEnabled:YES];
        [self.barkHistoryButton setEnabled:YES];
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
    [HDAudioUtils sharedInstance].micSensitivityLevel = [self convertSliderValueToSensitivity];
//    self.listener.micSensitivity = [self convertSliderValueToSensitivity];
    if([HDAudioUtils sharedInstance].micSensitivityLevel != [self retrieveSavedSensitivityValue]) {
        [self enableSaveButton];
    }
}

- (void)disableSaveButton {
    [self.saveSensitivityButton setTitle:@"Saved" forState:UIControlStateNormal];
    [self.saveSensitivityButton setEnabled:NO];
    [self.saveSensitivityButton setAlpha:0.5];
}

- (void)enableSaveButton {
    [self.saveSensitivityButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveSensitivityButton setEnabled:YES];
    [self.saveSensitivityButton setAlpha:1.0];
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

- (void)barkDetected {
    self.todaysBarkCount++;
    self.barkCountLabel.text = [NSString stringWithFormat:@"%ld today", (long)self.todaysBarkCount];
    [self.allBarks addObject:[NSDate date]];
    
    HDAudioUtils *audioUtil = [HDAudioUtils sharedInstance];
    [audioUtil playRandomSavedSound];
}

- (void)soundStartedPlaying {
    [self.toggleListeningButton setEnabled:NO];
}

- (void)soundFinishedPlaying {
    [self.toggleListeningButton setEnabled:YES];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL shouldPerform = YES;
    
    if([identifier isEqualToString:@"showHistorySegue"]) {
        if(self.allBarks.count < 1) {
            shouldPerform = NO;
            [self showAlertForNoHistory];
        }
    }
    
    return shouldPerform;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showHistorySegue"]) {
        HDBarkHistoryViewController *barkHistoryVC = (HDBarkHistoryViewController *)segue.destinationViewController;
        barkHistoryVC.barkHistory = self.allBarks;
        barkHistoryVC.delegate = self;
    } else if([segue.identifier isEqualToString:@"settingsSegue"]) {
        //get values to populate saved settings
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *dogName = [defaults objectForKey:kNSUserDefaultsDogNameKey];
        BOOL isListenerDevice = [defaults boolForKey:kNSUserDefaultsIsListeningDeviceKey];
        
        UINavigationController *navCon = (UINavigationController *)segue.destinationViewController;
        HDSettingsViewController *settingsVC = (HDSettingsViewController *)navCon.visibleViewController;
        settingsVC.nameString = dogName;
        settingsVC.isListenerDevice = isListenerDevice;
        
        UIPopoverPresentationController *ppc = settingsVC.popoverPresentationController;
        CGSize minimumSize = [settingsVC.view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        settingsVC.preferredContentSize = CGSizeMake(minimumSize.width, kSettingsPopoverHeight);
        ppc.delegate = self;
    }
}

- (void)showAlertForNoHistory {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No History" message:@"There is no history yet." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)saveBarksInUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.allBarks forKey:kUserDefaultsBarksHistoryKey];
    [defaults synchronize];
}

- (void)didClearHistory {
    [self.allBarks removeAllObjects];
    [self saveBarksInUserDefaults];
    [self checkIfOldBarksAreTodays];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self saveBarksInUserDefaults];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self saveBarksInUserDefaults];
}

- (IBAction)settingsButtonTapped:(id)sender {
    
}

#pragma mark - Popover Presentation Delegate Methods

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationOverFullScreen;
}

//- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style {
//    
//}

@end
