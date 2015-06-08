//
//  HDSoundsListTableViewController.m
//  HappyDogObjC
//
//  Created by Michael Otmanski on 5/24/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import "HDSoundsListTableViewController.h"
#import "HDSoundsCollector.h"
#import "HDSoundRecording.h"
#import <AVFoundation/AVFoundation.h>


@interface HDSoundsListTableViewController () <AVAudioPlayerDelegate>

@property(strong, nonatomic) NSArray *sounds;
@property(strong, nonatomic) AVAudioPlayer *audioPlayer;
@property(strong, nonatomic) AVAudioSession *audioSession;

@end

@implementation HDSoundsListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavigationItem];
    self.tableView.backgroundColor = [UIColor brownColor];
    self.tableView.separatorColor = [UIColor cyanColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchSounds];
}

- (void)fetchSounds {
    self.sounds = [[HDSoundsCollector sharedInstance] allSounds];
    [self.tableView reloadData];
}

- (void)addNavigationItem {
    UIBarButtonItem *addSoundButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewSound)];
    [self.navigationItem setRightBarButtonItem:addSoundButton];
    [self.navigationItem setTitle:@"My Sounds"];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.sounds count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recordingIdentifier" forIndexPath:indexPath];
    
    HDSoundRecording *currentSound = self.sounds[indexPath.row];
    cell.textLabel.text = currentSound.recordingName;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor brownColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HDSoundRecording *selectedSound = self.sounds[indexPath.row];
    NSString *fileName = selectedSound.recordingName;
    
    self.audioSession = [AVAudioSession sharedInstance];
    [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.audioSession setActive:YES error:nil];
    
    // sets the path for audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               [NSString stringWithFormat:@"%@.m4a", fileName],
                               nil];

    
    NSURL *recordedAudioURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    NSError *error;
    
    self.audioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:recordedAudioURL error:&error];
    self.audioPlayer.delegate = self;

    [self.audioPlayer play];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        HDSoundRecording *soundToRemove = self.sounds[indexPath.row];
        [[HDSoundsCollector sharedInstance] removeSound:soundToRemove];
        [self fetchSounds];
    }
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)createNewSound {
    [self performSegueWithIdentifier:@"createSoundSegue" sender:nil];
}

@end
