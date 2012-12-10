//
//  NSDate+XCExtensions.h
//  Calendar
//
//  Created by Grant Paul on 12/4/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSDateComponents+XCExtensions.h"

@interface NSDate (XCExtensions)

- (NSString *)monthName;
- (NSString *)weekdayName;
- (NSString *)dateName;

+ (NSDate *)dateForCalendarUnit:(NSCalendarUnit)unit;
- (NSDate *)dateOffsetBy:(NSInteger)offset unit:(NSCalendarUnit)unit;
- (NSInteger)units:(NSCalendarUnit)unit offsetFromDate:(NSDate *)date;

+ (NSDate *)today; // at mignight
- (NSDate *)dateOffsetByDays:(NSInteger)offset;
- (NSInteger)daysOffsetFromDate:(NSDate *)date;

+ (NSDate *)thisWeek; // at start of week
- (NSDate *)dateOffsetByWeeks:(NSInteger)offset;
- (NSInteger)weeksOffsetFromDate:(NSDate *)date;

+ (NSDate *)thisMonth; // start of this month
- (NSDate *)dateOffsetByMonths:(NSInteger)offset;
- (NSInteger)monthsOffsetFromDate:(NSDate *)date;

+ (NSDate *)thisYear; // start of year
- (NSDate *)dateOffsetByYears:(NSInteger)offset;
- (NSInteger)yearsOffsetFromDate:(NSDate *)date;

@end
