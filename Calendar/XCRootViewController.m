//
//  XCRootViewController.m
//  Calendar
//
//  Created by Grant Paul on 12/3/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "NSDate+XCExtensions.h"

#import "XCRootViewController.h"
#import "XCMonthViewController.h"

@interface XCRootViewController () <UIGestureRecognizerDelegate>

@end

@implementation XCRootViewController

- (id)initWithEventStore:(EKEventStore *)store {
    UIPageViewControllerTransitionStyle transitionStyle = UIPageViewControllerTransitionStyleScroll;
    UIPageViewControllerNavigationOrientation navigationOrientation = UIPageViewControllerNavigationOrientationHorizontal;
    NSDictionary *options = @{ UIPageViewControllerOptionInterPageSpacingKey : @0.0f };

    if ((self = [super initWithTransitionStyle:transitionStyle navigationOrientation:navigationOrientation options:options])) {
        self.store = store;
        self.delegate = self;
        self.dataSource = self;
    }

    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)calendarAccessGranted {
    XCMonthViewController *monthViewController = [[XCMonthViewController alloc] initWithStore:self.store date:[NSDate thisMonth]];
    [self setViewControllers:@[monthViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(XCMonthViewController *)viewController {
    NSDate *date = [[viewController date] dateOffsetByMonths:-1];
    
    XCMonthViewController *monthViewController = [[XCMonthViewController alloc] initWithStore:self.store date:date];
    [monthViewController autorelease];
    return monthViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(XCMonthViewController *)viewController {
    NSDate *date = [[viewController date] dateOffsetByMonths:1];
    
    XCMonthViewController *monthViewController = [[XCMonthViewController alloc] initWithStore:self.store date:date];
    [monthViewController autorelease];
    return monthViewController;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.scrollEnabled;
}

- (void)setViewControllers:(NSArray *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL))completion {

    if (self.transitionStyle == UIPageViewControllerTransitionStyleScroll && animated) {
        [super setViewControllers:viewControllers direction:direction animated:animated completion:^(BOOL finished) {
            if (finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Fix bug with scrolling page view controllers on iOS 6.
                    [super setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
                });
            }

            if (completion != NULL) {
                completion(finished);
            }
        }];
    } else {
        [super setViewControllers:viewControllers direction:direction animated:animated completion:completion];
    }
}

@end
