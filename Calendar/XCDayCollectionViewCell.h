//
//  XCDayCollectionViewCell.h
//  Calendar
//
//  Created by Grant Paul on 12/4/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface XCDayCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy, readonly) NSDate *date;
@property (nonatomic, copy, readonly) NSArray *events;
@property (nonatomic, assign, readonly) BOOL secondaryMonth;

- (void)updateForDate:(NSDate *)date events:(NSArray *)events secondaryMonth:(BOOL)secondary;

@end
