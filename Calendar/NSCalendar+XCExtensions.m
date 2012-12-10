//
//  NSCalendar+XCExtensions.m
//  Calendar
//
//  Created by Grant Paul on 12/4/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "NSCalendar+XCExtensions.h"

@implementation NSCalendar (XCExtensions)

+ (id)fastCalendar {
    static NSCalendar *calendar = nil;

    if (calendar == nil) {
        calendar = [[self currentCalendar] retain];
    }

    return calendar;
}

@end
