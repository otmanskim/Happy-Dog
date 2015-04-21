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

@property (strong, nonatomic) NSMutableArray *dateSections;
@property (strong, nonatomic) NSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UIView *toolbarBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *historyTitleLabel;

@end

@implementation HDBarkHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.calendar = [NSCalendar currentCalendar];
    self.historyTableView.delegate = self;
    self.historyTableView.dataSource = self;
    self.dateSections = [[NSMutableArray alloc] init];
    [self createSectionsArray];
    
    [self setupNavigationItems];
    [self setupUI];
}

- (void)setupNavigationItems {
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.toolbar setItems:@[flexibleSpace, closeButton] animated:NO];
}

- (void)setupUI {
    self.historyTableView.backgroundColor = [UIColor brownColor];
    [self.historyTableView setSeparatorColor:[UIColor cyanColor]];
    self.view.backgroundColor = [UIColor brownColor];
    [self.historyTitleLabel setTextColor:[UIColor brownColor]];
}

- (void)createSectionsArray {
    for(NSDate *date in self.barkHistory) {
        if(![self dateSectionsContainDate:date]) {
            //need to add this date to the sections array
            [self.dateSections addObject:[self dateStringFromDate:date]];
        }
    }
}

- (BOOL)dateSectionsContainDate:(NSDate *)date {
    BOOL containsDate = NO;
    if(self.dateSections.count > 0) {
        //something to check against
        for(NSString *currentDateString in self.dateSections) {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *currentDate = [formatter dateFromString:currentDateString];
            
            if([self date:date isOnSameDayAsDate:currentDate]) {
                containsDate = YES;
                break;
            }
        }
    }
    
    return containsDate;
}

- (BOOL)date:(NSDate *)date1 isOnSameDayAsDate:(NSDate *)date2 {
    BOOL sameDay = NO;
    NSDateComponents *componentsForFirstDate = [self.calendar components:NSCalendarUnitDay fromDate:date1];
    
    NSDateComponents *componentsForSecondDate = [self.calendar components:NSCalendarUnitDay fromDate:date2];
    
    if(componentsForFirstDate.day == componentsForSecondDate.day) {
        sameDay = YES;
    }
    
    return sameDay;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *daySection = self.dateSections[section];
    NSArray *datesInSection = [self getDatesForDay:daySection];
    
    return datesInSection.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(5, 0, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor brownColor];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor cyanColor];
    [view addSubview:label];
    
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *dateString = self.dateSections[section];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:dateString];
    
    formatter.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    formatter.dateFormat=@"MMMM";
    NSString * monthString = [[formatter stringFromDate:date] capitalizedString];
    
    formatter.dateFormat=@"eeee";
    NSString * dayString = [formatter stringFromDate:date];
    
    formatter.dateFormat = @"dd";
    NSString *dayNumberString = [formatter stringFromDate:date];
    
    formatter.dateFormat = @"yyyy";
    NSString *yearString = [formatter stringFromDate:date];
    
    NSString *sectionString = dayString;
    
    sectionString = [sectionString stringByAppendingString:[NSString stringWithFormat:@" %@ %@, %@", monthString, dayNumberString, yearString]];
    
    
    return sectionString;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dateSections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *daySection = self.dateSections[indexPath.section];
    NSArray *datesInSection = [self getDatesForDay:daySection];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"barkHistoryCellId"];
    
    NSDate *date = datesInSection[indexPath.row];
    NSString *dateString = [self timeStringFromDate:date];
    
    cell.textLabel.text = dateString;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor brownColor];
    
    
    return cell;
}

- (NSArray *)getDatesForDay:(NSString *)dateString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:dateString];
 
    
    NSMutableArray *datesForDay = [[NSMutableArray alloc] init];
    
    for(NSDate *currentDate in self.barkHistory) {
        if([self date:currentDate isOnSameDayAsDate:date]) {
            [datesForDay addObject:currentDate];
        }
    }
    
    return datesForDay;
}

- (NSString *)dateStringFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd"];

    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}

- (NSString *)timeStringFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat: @"yyyy-MM-dd, HH:mm:ss"];
    [formatter setDateFormat: @"hh:mm a"];

    
    NSString *stringFromDate = [formatter stringFromDate:date];
    
    return stringFromDate;
}

- (void)doneButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
