//
//  HDSettingsViewController.m
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/23/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import "HDSettingsViewController.h"
#import "HDConstants.h"
#import "AppDelegate.h"

@interface HDSettingsViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *dogNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *isListeningDeviceSwitch;

@end

@implementation HDSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self styleTextField];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    [self.view addGestureRecognizer:tapRecognizer];
    [self.view setBackgroundColor:[UIColor brownColor]];
    [self.isListeningDeviceSwitch setOn:self.isListenerDevice];
}

- (void)styleTextField {
    if(self.nameString.length > 0) {
        [self.dogNameTextField setText:self.nameString];
    }
    
    self.dogNameTextField.delegate = self;
    [self.dogNameTextField setBackgroundColor:[UIColor brownColor]];
    [self.dogNameTextField setTextColor:[UIColor cyanColor]];
    self.dogNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter dog name" attributes:@{NSForegroundColorAttributeName: [UIColor cyanColor]}];
    self.dogNameTextField.layer.borderColor = [UIColor cyanColor].CGColor;
    self.dogNameTextField.layer.borderWidth = 1.0;
    self.dogNameTextField.layer.masksToBounds = YES;
    self.dogNameTextField.tintColor = [UIColor whiteColor];
    self.dogNameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.dogNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    if([self validName]) {
        [self saveNewValues];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self showAlertForInvalidName];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.placeholder = @"";
}
- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if(textField.text.length < 1) {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter dog name" attributes:@{NSForegroundColorAttributeName: [UIColor cyanColor]}];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.text.length < 1) {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter dog name" attributes:@{NSForegroundColorAttributeName: [UIColor cyanColor]}];
    }
    
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)validName {
    BOOL valid = NO;
    NSString *name = self.dogNameTextField.text;
    
    if(name.length >= 1 && [self stringHasOnlyAlphaneumericCharacters:name]) {
        valid = YES;
    }
    
    return valid;
}

- (BOOL)stringHasOnlyAlphaneumericCharacters:(NSString *)string  {
    NSMutableCharacterSet *allowedCharacters = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
    
    BOOL valid = [[string stringByTrimmingCharactersInSet:allowedCharacters] isEqualToString:@""];
    return valid;
}

- (void)viewTapped {
    [self.dogNameTextField resignFirstResponder];
}

- (void)saveNewValues {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //if name has changed, stop listening to old channel
    if(self.nameString && ![self.dogNameTextField.text isEqualToString:self.nameString]) {
        [appDelegate stopListeningForCurrentChannel];
    }
    
    [defaults setObject:self.dogNameTextField.text forKey:kNSUserDefaultsDogNameKey];
    
    if(self.isListeningDeviceSwitch.isOn) {
        [defaults setBool:YES forKey:kNSUserDefaultsIsListeningDeviceKey];
    } else {
        [defaults setBool:NO forKey:kNSUserDefaultsIsListeningDeviceKey];
    }
    
    [appDelegate updatePushNotificationListenerChannel];
}

- (void)showAlertForInvalidName {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid Name" message:@"Your dog's name must have at least 1 letter." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
