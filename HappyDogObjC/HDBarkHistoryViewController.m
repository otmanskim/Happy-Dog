//
//  HDBarkHistoryViewController.m
//  HappyDogObjC
//
//  Created by Michael Otmanski on 4/19/15.
//  Copyright (c) 2015 Michael Otmanski. All rights reserved.
//

#import "HDBarkHistoryViewController.h"

@interface HDBarkHistoryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;

@end

@implementation HDBarkHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationItems];
    self.historyTableView.delegate = self;
    self.historyTableView.dataSource = self;
}

- (void)setupNavigationItems {
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.toolbar setItems:@[flexibleSpaceLeft, closeButton] animated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.barkHistory.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"barkHistoryCellId"];
    
    NSDate *date = self.barkHistory[indexPath.row];
    NSString *dateString = [self stringFromDate:date];
    
    cell.textLabel.text = dateString;
    
    return cell;
}

- (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd, HH:mm:ss"];
    
    NSString *stringFromDate = [formatter stringFromDate:date];
    
    return stringFromDate;
}

- (void)doneButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
