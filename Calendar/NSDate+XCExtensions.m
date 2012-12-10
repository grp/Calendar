//
//  NSDate+XCExtensions.m
//  Calendar
//
//  Created by Grant Paul on 12/4/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "NSCalendar+XCExtensions.h"
#import "NSDate+XCExtensions.h"

@implementation NSDate (XCExtensions)

+ (NSDate *)dateForCalendarUnit:(NSCalendarUnit)unit {
    NSDate *date = nil;

    NSCalendar *calendar = [NSCalendar fastCalendar];
    [calendar rangeOfUnit:unit startDate:&date interval:NULL forDate:[self date]];

    return date;
}

+ (NSDate *)today {
    return [self dateForCalendarUnit:NSDayCalendarUnit];
}

+ (NSDate *)thisWeek {
    return [self dateForCalendarUnit:NSWeekCalendarUnit];
}

+ (NSDate *)thisMonth {
    return [self dateForCalendarUnit:NSMonthCalendarUnit];
}

+ (NSDate *)thisYear {
    return [self dateForCalendarUnit:NSYearCalendarUnit];
}

- (NSDate *)dateOffsetBy:(NSInteger)offset unit:(NSCalendarUnit)unit {
    NSCalendar *calendar = [NSCalendar fastCalendar];

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setValue:offset forCalendarUnit:unit];
    NSDate *date = [calendar dateByAddingComponents:components toDate:self options:0];
    [components release];

    return date;
}

- (NSDate *)dateOffsetByDays:(NSInteger)offset {
    return [self dateOffsetBy:offset unit:NSDayCalendarUnit];
}

- (NSDate *)dateOffsetByWeeks:(NSInteger)offset {
    return [self dateOffsetBy:offset unit:NSWeekCalendarUnit];
}

- (NSDate *)dateOffsetByMonths:(NSInteger)offset {
    return [self dateOffsetBy:offset unit:NSMonthCalendarUnit];
}

- (NSDate *)dateOffsetByYears:(NSInteger)offset {
    return [self dateOffsetBy:offset unit:NSYearCalendarUnit];
}

- (NSInteger)units:(NSCalendarUnit)unit offsetFromDate:(NSDate *)date {
    NSDate *fromDate = nil;
    NSDate *toDate = nil;

    NSCalendar *calendar = [NSCalendar fastCalendar];

    [calendar rangeOfUnit:unit startDate:&fromDate interval:NULL forDate:date];
    [calendar rangeOfUnit:unit startDate:&toDate interval:NULL forDate:self];

    NSDateComponents *difference = [calendar components:unit fromDate:fromDate toDate:toDate options:0];
    return [difference valueForCalendarUnit:unit];
}

- (NSInteger)daysOffsetFromDate:(NSDate *)date {
    return [self units:NSDayCalendarUnit offsetFromDate:date];
}

- (NSInteger)weeksOffsetFromDate:(NSDate *)date {
    return [self units:NSWeekCalendarUnit offsetFromDate:date];
}

- (NSInteger)monthsOffsetFromDate:(NSDate *)date {
    return [self units:NSMonthCalendarUnit offsetFromDate:date];
}

- (NSInteger)yearsOffsetFromDate:(NSDate *)date {
    return [self units:NSYearCalendarUnit offsetFromDate:date];
}

- (NSString *)monthName {
    static NSDateFormatter *formatter = nil;

    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMMM";
    }

    return [formatter stringFromDate:self];
}

- (NSString *)weekdayName {
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEEE";
    }

    return [formatter stringFromDate:self];
}

- (NSString *)dateName {
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterLongStyle;
    }

    return [formatter stringFromDate:self];
}

@end
