//
//  XCDayCollectionViewCell.m
//  Calendar
//
//  Created by Grant Paul on 12/4/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "NSCalendar+XCExtensions.h"
#import "NSDate+XCExtensions.h"
#import "EKEventStore+XCExtensions.h"
#import "UIFont+XCExtensions.h"

#import "XCDotView.h"
#import "XCDayCollectionViewCell.h"

@interface XCDayCollectionViewCell ()

@property (nonatomic, copy, readwrite) NSDate *date;
@property (nonatomic, copy, readwrite) NSArray *events;
@property (nonatomic, assign, readwrite) BOOL secondaryMonth;

@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, copy) NSArray *dotViews;

@end

@implementation XCDayCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];

        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.font = [UIFont lightSystemFontOfSize:44.0f];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.dateLabel];
        [self.dateLabel release];
    }
    
    return self;
}

- (void)setDotViews:(NSArray *)dotViews {
    for (XCDotView *dotView in self.dotViews) {
        [dotView removeFromSuperview];
    }

    [_dotViews release];
    _dotViews = [dotViews copy];

    for (XCDotView *dotView in self.dotViews) {
        [self.contentView addSubview:dotView];

        if (self.secondaryMonth) {
            [dotView setAlpha:0.5f];
        }
    }

    [self setNeedsLayout];
}

- (void)layoutSubviews {
    self.dateLabel.frame = CGRectMake(5, 5, self.frame.size.width - 10, self.frame.size.height - 30);

    CGFloat padding = 5.0f;
    CGFloat dimension = 10.0f;
    CGFloat bottom = 10.0f;
    CGFloat width = (dimension * self.dotViews.count) + (padding * (self.dotViews.count - 1));
    CGFloat left = (self.frame.size.width - width) / 2;

    for (XCDotView *dotView in self.dotViews) {
        CGRect frame = dotView.frame;
        frame.origin.x = left;
        frame.origin.y = self.bounds.size.height - bottom - dimension;
        frame.size.width = dimension;
        frame.size.height = dimension;
        dotView.frame = frame;

        left += padding + dimension;
    }
}

- (void)updateForDate:(NSDate *)date events:(NSArray *)events secondaryMonth:(BOOL)secondary {
    self.date = date;
    self.events = events;
    self.secondaryMonth = secondary;

    NSCalendar *calendar = [NSCalendar fastCalendar];
    
    NSInteger ordinalDay = [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.date];
    self.dateLabel.text = [NSString stringWithFormat:@"%i", ordinalDay];

    NSDateComponents *differenceComponents = [calendar components:NSDayCalendarUnit fromDate:self.date toDate:[NSDate today] options:0];
    NSInteger todayDifferenceDays = differenceComponents.day;

    UIColor *color = nil;

    if (self.secondaryMonth) {
        color = [UIColor colorWithWhite:0.9f alpha:1.0f];
    } else if (todayDifferenceDays == 0) {
        color = [UIColor colorWithWhite:0.3f alpha:1.0f];
    } else {
        color = [UIColor colorWithWhite:0.6f alpha:1.0f];
    }

    self.dateLabel.textColor = color;

    NSMutableArray *dotViews = [NSMutableArray array];

    NSInteger maximumDots = 3;
    for (NSInteger i = 0; i < maximumDots && i < self.events.count; i++) {
        EKEvent *event = [self.events objectAtIndex:i];

        XCDotView *dotView = [[XCDotView alloc] initWithEvent:event];
        [dotViews addObject:dotView];
    }

    if (self.events.count > maximumDots) {
        XCDotView *moreView = [[XCDotView alloc] initForMore];
        [dotViews addObject:moreView];
    }

    self.dotViews = dotViews;
}

@end
