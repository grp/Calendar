//
//  XCMonthViewController.h
//  Calendar
//
//  Created by Grant Paul on 12/3/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface XCMonthViewController : UIViewController

- (id)initWithStore:(EKEventStore *)store date:(NSDate *)date;

@property (nonatomic, retain, readonly) EKEventStore *store;
@property (nonatomic, copy, readonly) NSDate *date;
@property (nonatomic, copy, readonly) NSArray *events;

@end
