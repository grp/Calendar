//
//  XCMonthViewController.m
//  Calendar
//
//  Created by Grant Paul on 12/3/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <EventKitUI/EventKitUI.h>
#import <QuartzCore/QuartzCore.h>

#import "EKEventStore+XCExtensions.h"
#import "NSCalendar+XCExtensions.h"
#import "NSDate+XCExtensions.h"
#import "UIFont+XCExtensions.h"

#import "NSObject+XNAnimation.h"

#import "XCMonthViewController.h"
#import "XCDayViewController.h"
#import "XCHeaderCollectionViewCell.h"
#import "XCDayCollectionViewCell.h"
#import "XCEventTableViewCell.h"
#import "XCEventView.h"
#import "XCRootViewController.h"

@interface XCMonthViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, XCDayViewControllerDelegate, XNAnimationDelegate>

@property (nonatomic, retain, readwrite) EKEventStore *store;
@property (nonatomic, copy, readwrite) NSDate *date;
@property (nonatomic, copy, readwrite) NSArray *events;

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, retain) UILabel *monthLabel;
@property (nonatomic, retain) UILabel *relativeLabel;

@property (nonatomic, retain) XCDayCollectionViewCell *presentingDayCell;
@property (nonatomic, retain) XCDayViewController *presentingDayViewController;
@property (nonatomic, assign) BOOL presentingDirectionIn;

@property (nonatomic, assign) BOOL appearedOnce;

@end

@implementation XCMonthViewController

- (void)displayUpdatedDate {
    [self.monthLabel setText:[self.date monthName]];

    NSInteger offset = [self.date monthsOffsetFromDate:[NSDate thisMonth]];

    if (offset == 0) {
        [self.relativeLabel setText:@"this month"];
    } else if (offset == 1) {
        [self.relativeLabel setText:@"next month"];
    } else if (offset == -1) {
        [self.relativeLabel setText:@"last month"];
    } else {
        NSCalendar *calendar = [NSCalendar fastCalendar];
        NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit fromDate:self.date];
        NSString *yearText = [NSString stringWithFormat:@"%i", dateComponents.year];
        
        [self.relativeLabel setText:yearText];
    }
}

- (void)setDate:(NSDate *)date {
    [_date release];
    _date = [date copy];

    [self displayUpdatedDate];
}

- (id)initWithStore:(EKEventStore *)store date:(NSDate *)date {
    if ((self = [super init])) {
        self.date = date;
        self.store = store;

        NSPredicate *predicate = [self.store predicateForEventsWithStartDate:self.date endDate:[self.date dateOffsetByMonths:1]];
        self.events = [self.store eventsMatchingPredicate:predicate];
        self.events = [self.events sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];
    }

    return self;
}

- (NSInteger)daysInWeek {
    NSCalendar *calendar = [NSCalendar fastCalendar];
    NSDate *offsetDate = [self.date dateOffsetByWeeks:1]; // must be in a full week
    NSRange weekRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:offsetDate];

    return weekRange.length;
}

- (NSInteger)rows {
    return 5;
}

- (CGSize)itemSize {
    return CGSizeMake(80, 90);
}

- (CGSize)headerSize {
    return CGSizeMake([self itemSize].width, 45);
}

- (void)loadView {
    [super loadView];

    self.view.backgroundColor = [UIColor whiteColor];

    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumInteritemSpacing = (1.0f / [[UIScreen mainScreen] scale]);
    self.flowLayout.minimumLineSpacing = (1.0f / [[UIScreen mainScreen] scale]);
    [self.flowLayout release];

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    self.collectionView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin);
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[XCHeaderCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([XCHeaderCollectionViewCell class])];
    [self.collectionView registerClass:[XCDayCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([XCDayCollectionViewCell class])];

    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    self.collectionView.layer.borderColor = [[UIColor colorWithWhite:0.5f alpha:1.0f] CGColor];
    self.collectionView.layer.borderWidth = 1.0f;
    
    [self.view addSubview:self.collectionView];
    [self.collectionView release];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[XCEventTableViewCell class] forCellReuseIdentifier:NSStringFromClass([XCEventTableViewCell class])];

    self.tableView.layer.cornerRadius = 10.0f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.view addSubview:self.tableView];
    [self.tableView release];

    self.monthLabel = [[UILabel alloc] init];
    self.monthLabel.font = [UIFont lightSystemFontOfSize:72.0f];
    self.monthLabel.textAlignment = NSTextAlignmentLeft;
    self.monthLabel.textColor = [UIColor colorWithWhite:0.474f alpha:1.0f];
    [self.view addSubview:self.monthLabel];
    [self.monthLabel release];

    self.relativeLabel = [[UILabel alloc] init];
    self.relativeLabel.font = [UIFont lightSystemFontOfSize:60.0f];
    self.relativeLabel.textAlignment = NSTextAlignmentRight;
    self.relativeLabel.textColor = [UIColor colorWithWhite:0.663f alpha:1.0f];
    [self.view addSubview:self.relativeLabel];
    [self.relativeLabel release];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat horizontalInset = 80;

    CGRect collectionFrame = CGRectZero;
    collectionFrame.size.width = self.itemSize.width * [self daysInWeek] + self.flowLayout.minimumInteritemSpacing * ([self daysInWeek] - 1);
    collectionFrame.size.height = self.itemSize.height * [self rows] + self.flowLayout.minimumLineSpacing * ([self rows] - 1) + self.headerSize.height;
    collectionFrame.origin.x = self.view.bounds.size.width - collectionFrame.size.width - horizontalInset;
    collectionFrame.origin.y = 185;
    self.collectionView.frame = collectionFrame;

    CGRect tableFrame = CGRectZero;
    tableFrame.origin.x = horizontalInset;
    tableFrame.origin.y = collectionFrame.origin.y;
    tableFrame.size.width = collectionFrame.origin.x - tableFrame.origin.x - 30;
    tableFrame.size.height = collectionFrame.size.height;
    self.tableView.frame = tableFrame;

    CGFloat labelWidth = (self.view.bounds.size.width - horizontalInset - horizontalInset) / 2;
    self.monthLabel.frame = CGRectMake(horizontalInset, 165 - 100 + self.monthLabel.font.descender, labelWidth, 100);
    self.relativeLabel.frame = CGRectMake(self.view.bounds.size.width - horizontalInset - labelWidth, 165 - 100 + self.relativeLabel.font.descender, labelWidth, 100);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self displayUpdatedDate];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.collectionView flashScrollIndicators];

    if (!self.appearedOnce) {
        self.appearedOnce = YES;
        [self.tableView reloadData];

        NSInteger index = [self.events indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            EKEvent *event = obj;

            return [event.startDate compare:[NSDate date]] == NSOrderedDescending;
        }];

        if (index != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];

            if (self.tableView.contentOffset.y + self.tableView.bounds.size.height > self.tableView.contentSize.height) {
                self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
            }
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([XCEventTableViewCell class]) forIndexPath:indexPath];

    cell.padding = 5.0f;
    [cell updateWithEvent:self.events[indexPath.row]];
    cell.eventView.margin = 15.0f;

    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return [self daysInWeek];
    } else if (section == 1) {
        NSCalendar *calendar = [NSCalendar fastCalendar];

        NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.date];
        NSDateComponents *dateComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self.date];

        NSInteger days = dayRange.length + dateComponents.weekday - 1; // weekdays start at 1

        if (days < [self daysInWeek] * [self rows]) {
            days = [self daysInWeek] * [self rows];
        } else {
            days += [self daysInWeek] - (days % [self daysInWeek]);
        }
        
        return days;
    } else {
        return 0;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        return [self headerSize];
    } else if ([indexPath section] == 1) {
        return [self itemSize];
    } else {
        return CGSizeZero;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSCalendar *calendar = [NSCalendar fastCalendar];

    if ([indexPath section] == 0) {
        XCHeaderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XCHeaderCollectionViewCell class]) forIndexPath:indexPath];

        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.day = indexPath.item;
        NSDate *date = [calendar dateByAddingComponents:components toDate:[NSDate thisWeek] options:0];
        [components release];

        cell.title = [date weekdayName];

        // UICollectionView doesn't leave a gap between sections. Fake it.
        UIView *borderView = [[UIView alloc] init];
        borderView.layer.backgroundColor = collectionView.layer.borderColor;
        borderView.frame = CGRectMake(0, cell.contentView.bounds.size.height - 1.0f, cell.contentView.bounds.size.width, 1.0f);
        [cell.contentView addSubview:borderView];
        [borderView release];

        return cell;
    } else if ([indexPath section] == 1) {
        XCDayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XCDayCollectionViewCell class]) forIndexPath:indexPath];

        NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.date];
        NSDateComponents *dateComponents = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSEraCalendarUnit | NSWeekdayCalendarUnit) fromDate:self.date];

        NSInteger index = indexPath.item;
        NSInteger count = dayRange.length;
        NSInteger first = dateComponents.weekday - 1; // weekdays start at 1

        NSInteger day = index - first;
        NSDate *date = [self.date dateOffsetByDays:day];
        NSDate *endDate = [date dateOffsetByDays:1];
        BOOL secondary = (index < first || index >= first + count);

        NSArray *events = [self.events objectsAtIndexes:[self.events indexesOfObjectsPassingTest:^BOOL (EKEvent *obj, NSUInteger idx, BOOL *stop) {
            if ([date compare:obj.endDate] == NSOrderedAscending && [endDate compare:obj.startDate] == NSOrderedDescending) {
                return YES;
            } else {
                return NO;
            }
        }]];
        
        [cell updateForDate:date events:events secondaryMonth:secondary];
        
        return cell;
    } else {
        return nil;
    }
}

- (UIView *)dayViewController:(XCDayViewController *)dayViewController viewForGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    return self.view.window;
}

- (void)dayViewController:(XCDayViewController *)dayViewController panFromGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    UIGestureRecognizerState state = recognizer.state;

    if (state == UIGestureRecognizerStateBegan) {
        [self.presentingDayViewController.view removeAllXNAnimations];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:NULL];
            [self.view addSubview:self.presentingDayViewController.view];
        });
    } else if (state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self.view];
        CGRect frame = CGRectMake(0, translation.y, self.presentingDayViewController.view.bounds.size.width, self.presentingDayViewController.view.bounds.size.height);
        [self.presentingDayViewController.view setFrame:frame];
    } else {
        CGPoint velocity = [recognizer velocityInView:self.view];

        if (velocity.y < 0) {
            self.presentingDirectionIn = YES;

            XNAnimation *animation = [XNAnimation animationWithKeyPath:@"frame.origin"];
            animation.delegate = self;
            animation.timingFunction = [XNSpringTimingFunction timingFunction];
            animation.velocity = [NSValue valueWithCGPoint:CGPointMake(0, velocity.y)];
            animation.toValue = [NSValue valueWithCGPoint:CGPointZero];
            [self.presentingDayViewController.view addXNAnimation:animation];
        } else {
            self.presentingDirectionIn = NO;
            
            CGPoint center = [self.view convertPoint:self.presentingDayCell.center fromView:self.presentingDayCell.superview];

            CGRect frame = self.presentingDayViewController.view.frame;
            self.presentingDayViewController.view.center = center;
            self.presentingDayViewController.view.frame = frame;

            CGPoint toCenter = self.presentingDayViewController.view.center;
            toCenter.y -= frame.origin.y;

            CGPoint scale = CGPointMake(self.presentingDayCell.bounds.size.width / self.view.bounds.size.width, self.presentingDayCell.bounds.size.height / self.view.bounds.size.height);
            CGFloat scaledVelocity = (velocity.y / self.view.bounds.size.height);

            XNAnimation *animation = [XNAnimation animationWithKeyPath:@"transform.scale.x"];
            animation.timingFunction = [XNSpringTimingFunction timingFunctionWithTension:200 damping:20 mass:1.0f];
            animation.velocity = [NSNumber numberWithFloat:scaledVelocity];
            animation.toValue = [NSNumber numberWithFloat:scale.x];
            [self.presentingDayViewController.view addXNAnimation:animation];

            animation = [XNAnimation animationWithKeyPath:@"transform.scale.y"];
            animation.timingFunction = [XNSpringTimingFunction timingFunctionWithTension:200 damping:20 mass:1.0f];
            animation.velocity = [NSNumber numberWithFloat:scaledVelocity];
            animation.toValue = [NSNumber numberWithFloat:scale.y];
            [self.presentingDayViewController.view addXNAnimation:animation];

            XNAnimation *centerAnimation = [XNAnimation animationWithKeyPath:@"center"];
            centerAnimation.delegate = self;
            centerAnimation.timingFunction = [XNSpringTimingFunction timingFunctionWithTension:200 damping:20 mass:1.0f];
            centerAnimation.velocity = [NSValue valueWithCGPoint:velocity];
            centerAnimation.toValue = [NSValue valueWithCGPoint:toCenter];
            [self.presentingDayViewController.view addXNAnimation:centerAnimation];
        }
    }
}

- (void)animationStopped:(XNAnimation *)animation {
    if (self.presentingDirectionIn) {
        if (self.presentedViewController == nil) {
            self.presentingDayViewController.view.frame = self.view.bounds;
            [self presentViewController:self.presentingDayViewController animated:NO completion:NULL];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.presentingDayViewController.view removeAllXNAnimations];
            });

            XCRootViewController *root = (XCRootViewController *) self.parentViewController;
            root.scrollEnabled = YES;
        }
    } else {
        [self.presentingDayViewController.view removeFromSuperview];
        self.presentingDayViewController = nil;
    }
}

- (void)dayViewControllerWantsRepresentAfterRotation:(XCDayViewController *)dayViewController {
    [self dismissViewControllerAnimated:NO completion:NULL];
    [self.view addSubview:self.presentingDayViewController.view];
    self.presentingDayViewController.view.frame = self.view.bounds;
    [self presentViewController:self.presentingDayViewController animated:NO completion:NULL];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        self.presentingDayCell = (id) [self.collectionView cellForItemAtIndexPath:indexPath];
        CGPoint center = [self.view convertPoint:self.presentingDayCell.center fromView:self.presentingDayCell.superview];

        [self.presentingDayViewController.view removeAllXNAnimations];

        self.presentingDayViewController = [[XCDayViewController alloc] initWithDate:self.presentingDayCell.date events:self.presentingDayCell.events store:self.store];
        self.presentingDayViewController.delegate = self;
        self.presentingDayViewController.view.layer.anchorPoint = CGPointMake(center.x / self.view.bounds.size.width, center.y / self.view.bounds.size.height);
        self.presentingDayViewController.view.frame = self.view.bounds;
        [self.view addSubview:self.presentingDayViewController.view];

        CGPoint scale = CGPointMake(self.presentingDayCell.bounds.size.width / self.view.bounds.size.width, self.presentingDayCell.bounds.size.height / self.view.bounds.size.height);
        self.presentingDayViewController.view.transform = CGAffineTransformMakeScale(scale.x, scale.y);

        self.presentingDirectionIn = YES;

        XCRootViewController *root = (XCRootViewController *) self.parentViewController;
        root.scrollEnabled = NO;

        XNSpringTimingFunction *timingFunction = [XNSpringTimingFunction timingFunctionWithTension:273 damping:35 mass:0.02];

        XNAnimation *animation = [XNAnimation animationWithKeyPath:@"transform.scale.x"];
        animation.delegate = self;
        animation.timingFunction = timingFunction;
        animation.velocity = [NSNumber numberWithFloat:5.0];
        animation.fromValue = [NSNumber numberWithFloat:scale.x];
        animation.toValue = [NSNumber numberWithFloat:1.0];
        [self.presentingDayViewController.view addXNAnimation:animation];

        animation = [XNAnimation animationWithKeyPath:@"transform.scale.y"];
        animation.delegate = self;
        animation.timingFunction = timingFunction;
        animation.velocity = [NSNumber numberWithFloat:5.0];
        animation.fromValue = [NSNumber numberWithFloat:scale.y];
        animation.toValue = [NSNumber numberWithFloat:1.0];
        [self.presentingDayViewController.view addXNAnimation:animation];
    }
}

@end
