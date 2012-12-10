//
//  NSDateComponents+XCExtensions.h
//  Calendar
//
//  Created by Grant Paul on 12/4/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateComponents (XCExtensions)

- (NSInteger)valueForCalendarUnit:(NSCalendarUnit)unit;
- (void)setValue:(NSInteger)value forCalendarUnit:(NSCalendarUnit)unit;

@end
