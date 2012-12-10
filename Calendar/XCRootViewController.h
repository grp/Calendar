//
//  XCRootViewController.h
//  Calendar
//
//  Created by Grant Paul on 12/3/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <EventKit/EventKit.h>

@interface XCRootViewController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

- (id)initWithEventStore:(EKEventStore *)store;
- (void)calendarAccessGranted;

@property (nonatomic, retain) EKEventStore *store;

@property (nonatomic, assign) BOOL scrollEnabled;

@end
