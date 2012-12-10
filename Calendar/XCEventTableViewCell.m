//
//  XCEventTableViewCell.m
//  Calendar
//
//  Created by Grant Paul on 12/7/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "XCEventView.h"
#import "XCEventTableViewCell.h"

#import "EKEvent+XCExtensions.h"

@interface XCEventTableViewCell ()

@property (nonatomic, retain, readwrite) XCEventView *eventView;

@end

@implementation XCEventTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.padding = 4.0f;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if ([self.contentView.subviews indexOfObject:self.eventView] != NSNotFound) {
        CGRect eventFrame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height - self.padding);
        self.eventView.frame = eventFrame;
    }
}

- (void)setPadding:(CGFloat)padding {
    _padding = padding;

    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    UIColor *color = self.eventView.event.displayColor;

    if (highlighted) {
        CGFloat red, green, blue, alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];

        red *= 0.7;
        green *= 0.7;
        blue *= 0.7;

        color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    }

    if (animated) {
        [UIView animateWithDuration:0.3f animations:^{
            self.eventView.backgroundColor = color;
        }];
    } else {
        self.eventView.backgroundColor = color;
    }
}

- (void)updateWithEvent:(EKEvent *)event {
    [self.eventView removeFromSuperview];

    self.eventView = [[XCEventView alloc] initWithEvent:event];
    [self.contentView addSubview:self.eventView];
    [self.eventView release];

    [self setNeedsLayout];
}

@end
