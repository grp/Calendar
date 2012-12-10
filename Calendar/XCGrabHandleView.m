//
//  XCGrabHandleView.m
//  Calendar
//
//  Created by Grant Paul on 12/9/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "XCGrabHandleView.h"

@implementation XCGrabHandleView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
    }

    return self;
}

- (void)drawRect:(CGRect)rect {
    CGFloat part = (rect.size.height / 10);

    CGFloat barParts = 2;
    CGFloat paddingParts = 2;

    CGRect topRect = CGRectMake(0, 0, rect.size.width, barParts * part);
    CGRect middleRect = CGRectMake(0, CGRectGetMaxY(topRect) + paddingParts * part, rect.size.width, barParts * part);
    CGRect bottomRect = CGRectMake(0, CGRectGetMaxY(middleRect) + paddingParts * part, rect.size.width, barParts * part);

    CGFloat radius = (barParts * part) / 2;

    UIBezierPath *topBezierPath = [UIBezierPath bezierPathWithRoundedRect:topRect cornerRadius:radius];
    UIBezierPath *middleBezierPath = [UIBezierPath bezierPathWithRoundedRect:middleRect cornerRadius:radius];
    UIBezierPath *bottomBezierPath = [UIBezierPath bezierPathWithRoundedRect:bottomRect cornerRadius:radius];

    [[UIColor colorWithWhite:0.75f alpha:1.0f] set];

    [topBezierPath fill];
    [middleBezierPath fill];
    [bottomBezierPath fill];
}

@end
