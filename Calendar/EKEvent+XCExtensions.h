//
//  EKEvent+XCExtensions.h
//  Calendar
//
//  Created by Grant Paul on 12/4/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <EventKit/EventKit.h>

typedef enum {
    kEKXCEventDueDatePast,
    kEKXCEventDueDateCurrent,
    kEKXCEventDueDateFuture
} EKXCEventDueDate;

@interface EKEvent (XCExtensions)

@property (nonatomic, assign, getter = isCompleted) BOOL completed;
@property (nonatomic, assign, getter = isImportant) BOOL important;
@property (nonatomic, assign, readonly) EKXCEventDueDate dueDate;
@property (nonatomic, copy, readonly) NSString *displayTitle;
@property (nonatomic, retain, readonly) UIColor *displayColor;

+ (EKXCEventDueDate)dueDateForStartDate:(NSDate *)start endDate:(NSDate *)end allDay:(BOOL)allDay;
+ (UIColor *)displayColorForCompleted:(BOOL)completed dueDate:(EKXCEventDueDate)due;

@end
