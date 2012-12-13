//
//  XCDayViewController.h
//  Calendar
//
//  Created by Grant Paul on 12/3/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@protocol XCDayViewControllerDelegate;

@interface XCDayViewController : UIViewController

- (id)initWithDate:(NSDate *)date events:(NSArray *)events store:(EKEventStore *)store;

@property (nonatomic, assign) id<XCDayViewControllerDelegate> delegate;

@end

@protocol XCDayViewControllerDelegate <NSObject>

- (UIView *)dayViewController:(XCDayViewController *)dayViewController viewForGestureRecognizer:(UIPanGestureRecognizer *)recognizer;
- (void)dayViewController:(XCDayViewController *)dayViewController panFromGestureRecognizer:(UIPanGestureRecognizer *)recognizer;
- (void)dayViewControllerWantsRepresentAfterRotation:(XCDayViewController *)dayViewController;

@end
