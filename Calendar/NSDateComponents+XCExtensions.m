//
//  NSDateComponents+XCExtensions.m
//  Calendar
//
//  Created by Grant Paul on 12/4/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "NSDateComponents+XCExtensions.h"

@implementation NSDateComponents (XCExtensions)

- (NSInteger)valueForCalendarUnit:(NSCalendarUnit)unit {
    if (unit && !(unit & (unit - 1))) { // only single bit set
        if (unit == NSEraCalendarUnit) {
            return self.era;
        } else if (unit == NSYearCalendarUnit) {
            return self.year;
        } else if (unit == NSMonthCalendarUnit) {
            return self.month;
        } else if (unit == NSDayCalendarUnit) {
            return self.day;
        } else if (unit == NSHourCalendarUnit) {
            return self.hour;
        } else if (unit == NSMinuteCalendarUnit) {
            return self.minute;
        } else if (unit == NSSecondCalendarUnit) {
            return self.second;
        } else if (unit == NSWeekCalendarUnit) {
            return self.week;
        } else if (unit == NSWeekdayCalendarUnit) {
            return self.weekday;
        } else if (unit == NSWeekdayOrdinalCalendarUnit) {
            return self.weekdayOrdinal;
        } else if (unit == NSQuarterCalendarUnit) {
            return self.quarter;
        } else if (unit == NSWeekOfMonthCalendarUnit) {
            return self.weekOfMonth;
        } else if (unit == NSWeekOfYearCalendarUnit) {
            return self.weekOfYear;
        } else if (unit == NSCalendarCalendarUnit) {
            [NSException raise:@"NSDateComponents+XCExtensionsInvalidCalendarUnitException" format:@"calendar unit invalid"];
            return 0;
        } else if (unit == NSTimeZoneCalendarUnit) {
            [NSException raise:@"NSDateComponents+XCExtensionsInvalidCalendarUnitException" format:@"time zone unit invalid"];
            return 0;
        } else {
            [NSException raise:@"NSDateComponents+XCExtensionsInvalidCalendarUnitException" format:@"unknown calendar unit"];
            return 0;
        }
    } else {
        [NSException raise:@"NSDateComponents+XCExtensionsInvalidCalendarUnitException" format:@"only one unit, please"];
        return 0;
    }
}

- (void)setValue:(NSInteger)value forCalendarUnit:(NSCalendarUnit)unit {
    if (unit && !(unit & (unit - 1))) { // only single bit set
        if (unit == NSEraCalendarUnit) {
            self.era = value;
        } else if (unit == NSYearCalendarUnit) {
            self.year = value;
        } else if (unit == NSMonthCalendarUnit) {
            self.month = value;
        } else if (unit == NSDayCalendarUnit) {
            self.day = value;
        } else if (unit == NSHourCalendarUnit) {
            self.hour = value;
        } else if (unit == NSMinuteCalendarUnit) {
            self.minute = value;
        } else if (unit == NSSecondCalendarUnit) {
            self.second = value;
        } else if (unit == NSWeekCalendarUnit) {
            self.week = value;
        } else if (unit == NSWeekdayCalendarUnit) {
            self.weekday = value;
        } else if (unit == NSWeekdayOrdinalCalendarUnit) {
            self.weekdayOrdinal = value;
        } else if (unit == NSQuarterCalendarUnit) {
            self.quarter = value;
        } else if (unit == NSWeekOfMonthCalendarUnit) {
            self.weekOfMonth = value;
        } else if (unit == NSWeekOfYearCalendarUnit) {
            self.weekOfYear = value;
        } else if (unit == NSCalendarCalendarUnit) {
            [NSException raise:@"NSDateComponents+XCExtensionsInvalidCalendarUnitException" format:@"calendar unit invalid"];
        } else if (unit == NSTimeZoneCalendarUnit) {
            [NSException raise:@"NSDateComponents+XCExtensionsInvalidCalendarUnitException" format:@"time zone unit invalid"];
        } else {
            [NSException raise:@"NSDateComponents+XCExtensionsInvalidCalendarUnitException" format:@"unknown calendar unit"];
        }
    } else {
        [NSException raise:@"NSDateComponents+XCExtensionsInvalidCalendarUnitException" format:@"only one unit, please"];
    }
}

@end
