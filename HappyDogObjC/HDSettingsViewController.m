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
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation HDSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self styleTextField:self.dogNameTextField];
    [self styleTextField:self.emailTextField];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    [self.view addGestureRecognizer:tapRecognizer];
    [self.view setBackgroundColor:[UIColor brownColor]];
    [self.isListeningDeviceSwitch setOn:self.isListenerDevice];
}

- (void)styleTextField:(UITextField *)textField {
    BOOL dogNameTextField = textField == self.dogNameTextField;
    
    if(dogNameTextField) {
        if(self.nameString.length > 0) {
            [textField setText:self.nameString];
        } else {
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter dog name" attributes:@{NSForegroundColorAttributeName: [UIColor cyanColor]}];
        }
    } else {
        if(self.emailString.length > 0) {
            [textField setText:self.emailString];
        } else {
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter email" attributes:@{NSForegroundColorAttributeName: [UIColor cyanColor]}];
        }
    }
    
    textField.delegate = self;
    [textField setBackgroundColor:[UIColor brownColor]];
    [textField setTextColor:[UIColor cyanColor]];
    textField.layer.borderColor = [UIColor cyanColor].CGColor;
    textField.layer.borderWidth = 1.0;
    textField.layer.masksToBounds = YES;
    textField.tintColor = [UIColor whiteColor];
    if(dogNameTextField) {
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    } else {
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
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
        if(textField == self.dogNameTextField) {
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter dog name" attributes:@{NSForegroundColorAttributeName: [UIColor cyanColor]}];
        } else if(textField == self.emailTextField) {
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter email" attributes:@{NSForegroundColorAttributeName: [UIColor cyanColor]}];

        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.text.length < 1) {
        if(textField == self.dogNameTextField) {
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter dog name" attributes:@{NSForegroundColorAttributeName: [UIColor cyanColor]}];
        } else if(textField == self.emailTextField) {
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter email" attributes:@{NSForegroundColorAttributeName: [UIColor cyanColor]}];
        }
    }
    
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)validName {
    BOOL valid = NO;
    NSString *name = self.dogNameTextField.text;
    NSString *email = self.emailTextField.text;
    
    if(name.length >= 1 && email.length >= 1 && [self stringHasOnlyAlphaneumericCharacters:name]) {
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
    [self.emailTextField resignFirstResponder];
}

- (void)saveNewValues {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //if values have changed, stop listening to old channel
    if([self nameOrEmailHasChanged]) {
        [appDelegate stopListeningForCurrentChannel];
    }
    
    [defaults setObject:self.dogNameTextField.text forKey:kNSUserDefaultsDogNameKey];
    [defaults setObject:self.emailTextField.text forKey:kNSUserDefaultsEmailKey];
    
    if(self.isListeningDeviceSwitch.isOn) {
        [defaults setBool:YES forKey:kNSUserDefaultsIsListeningDeviceKey];
    } else {
        [defaults setBool:NO forKey:kNSUserDefaultsIsListeningDeviceKey];
    }
    
    [appDelegate updatePushNotificationListenerChannel];
}

- (BOOL)nameOrEmailHasChanged {
    BOOL nameHasChanged = NO;
    BOOL emailHasChanged = NO;
    
    if(self.nameString && ![self.dogNameTextField.text isEqualToString:self.nameString]) {
        nameHasChanged = YES;
    }
    
    if(self.emailString && ![self.emailTextField.text isEqualToString:self.emailString]) {
        emailHasChanged = YES;
    }
    
    return nameHasChanged || emailHasChanged;
}

- (void)showAlertForInvalidName {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid Name or Email" message:@"Your email and your dog's name must have at least 1 letter." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
