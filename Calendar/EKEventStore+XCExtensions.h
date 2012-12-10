//
//  EKEventStore+XCExtensions.h
//  Calendar
//
//  Created by Grant Paul on 12/4/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <EventKit/EventKit.h>

@interface EKEventStore (XCExtensions)

- (void)refreshAllowedCalendarsCache;
- (NSPredicate *)predicateForEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
