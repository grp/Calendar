//
//  EKEvent+XCExtensions.m
//  Calendar
//
//  Created by Grant Paul on 12/4/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "NSDate+XCExtensions.h"
#import "EKEvent+XCExtensions.h"

@implementation EKEvent (XCExtensions)

- (BOOL)isCompleted {
    return [self.title hasPrefix:@"DONE: "] || !self.allDay;
}

- (void)setCompleted:(BOOL)completed {
    if (completed == self.completed || !self.allDay) {
        return;
    }

    if (completed) {
        self.title = [@"DONE: " stringByAppendingString:self.title];
    } else {
        self.title = [self.title substringFromIndex:[@"DONE: " length]];
    }
}

- (BOOL)isImportant {
    return [self.title rangeOfString:@"test" options:NSCaseInsensitiveSearch].location != NSNotFound;
}

- (void)setImportant:(BOOL)important {
    if (important == self.important) {
        return;
    }

    [NSException raise:@"EKEvent+XCExtensionsUnimplementedException" format:@"setting important state isn't implemented yet"];
}

+ (EKXCEventDueDate)dueDateForStartDate:(NSDate *)start endDate:(NSDate *)end allDay:(BOOL)allDay {
    NSDate *now = [NSDate date];

    if (allDay) {
        // Make it really all day, rather than 8am to 8pm or so.
        now = [NSDate today];
        start = [start dateOffsetByDays:0];
        end = [end dateOffsetByDays:1];
    }

    if ([now compare:start] == NSOrderedAscending) {
        return kEKXCEventDueDateFuture;
    } else if ([now compare:end] == NSOrderedDescending) {
        return kEKXCEventDueDatePast;
    } else {
        return kEKXCEventDueDateCurrent;
    }
}

- (EKXCEventDueDate)dueDate {
    return [[self class] dueDateForStartDate:self.startDate endDate:self.endDate allDay:self.allDay];
}

- (NSString *)displayTitle {
    NSString *title = self.title;

    if ([self.title hasPrefix:@"DONE: "]) {
        title = [title substringFromIndex:[@"DONE: " length]];
    }

    if (self.important) {
        title = [@"\u2605 " stringByAppendingString:title];
    }

    return title;
}

+ (UIColor *)displayColorForCompleted:(BOOL)completed dueDate:(EKXCEventDueDate)due {
    if (completed) {
        if (due == kEKXCEventDueDatePast) {
            return [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
        } else if (due == kEKXCEventDueDateCurrent) {
            return [UIColor colorWithRed:0.2f green:0.55f blue:0.2f alpha:1.0f];
        } else if (due == kEKXCEventDueDateFuture) {
            return [UIColor colorWithRed:0.2f green:0.55f blue:0.2f alpha:1.0f];
        } else {
            [NSException raise:@"EKEvent+XCExtensionsInvalidDueDateException" format:@"invalid due date"];
            return nil;
        }
    } else {
        if (due == kEKXCEventDueDatePast) {
            return [UIColor colorWithRed:0.7f green:0.0f blue:0.0f alpha:1.0f];
        } else if (due == kEKXCEventDueDateCurrent) {
            return [UIColor colorWithRed:0.7f green:0.0f blue:0.0f alpha:1.0f];
        } else if (due == kEKXCEventDueDateFuture) {
            return [UIColor colorWithRed:0.45f green:0.45f blue:0.5f alpha:1.0f];
        } else {
            [NSException raise:@"EKEvent+XCExtensionsInvalidDueDateException" format:@"invalid due date"];
            return nil;
        }
    }
}

- (UIColor *)displayColor {
    return [[self class] displayColorForCompleted:self.completed dueDate:self.dueDate];
}

@end
