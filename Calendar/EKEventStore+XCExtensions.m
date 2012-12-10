//
//  EKEventStore+XCExtensions.m
//  Calendar
//
//  Created by Grant Paul on 12/4/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <objc/runtime.h>

#import "EKEventStore+XCExtensions.h"

static NSString *EKEventStoreXCExtensionsAllowedCalendarsCacheKey = @"XKEventStoreXCExtensionsAllowedCalendarsCache";

@implementation EKEventStore (XCExtensions)

- (void)refreshAllowedCalendarsCache {
    NSArray *calendars = [self calendarsForEntityType:EKEntityTypeEvent];
    NSMutableArray *allowedCalendars = [calendars mutableCopy];

    for (EKCalendar *calendar in calendars) {
        EKSource *source = [calendar source];

        if (source.sourceType == EKSourceTypeBirthdays || [source.title rangeOfString:@"Facebook"].location != NSNotFound) {
            [allowedCalendars removeObject:calendar];
        }
    }

    objc_setAssociatedObject(self, &EKEventStoreXCExtensionsAllowedCalendarsCacheKey, allowedCalendars, OBJC_ASSOCIATION_COPY_NONATOMIC);

    [allowedCalendars release];
}

- (NSPredicate *)predicateForEventsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSArray *allowedCalendars = objc_getAssociatedObject(self, &EKEventStoreXCExtensionsAllowedCalendarsCacheKey);

    NSPredicate *predicate = [self predicateForEventsWithStartDate:startDate endDate:endDate calendars:allowedCalendars];
    return predicate;
}

@end
