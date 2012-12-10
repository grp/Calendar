//
//  XCDotView.m
//  Calendar
//
//  Created by Grant Paul on 12/4/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "EKEvent+XCExtensions.h"

#import "XCDotView.h"

typedef enum {
    kXCDotViewStyleDefault,
    kXCDotViewStyleSpecial,
    kXCDotViewStyleMore
} XCDotViewStyle;

@interface XCDotView ()

@property (nonatomic, assign) XCDotViewStyle style;
@property (nonatomic, retain) EKEvent *event;

@end

@implementation XCDotView

- (id)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor clearColor];
        self.color = [UIColor redColor];
    }

    return self;
}

- (id)initWithEvent:(EKEvent *)event {
    if ((self = [self init])) {
        self.event = event;

        if (event.important) {
            self.style = kXCDotViewStyleSpecial;
        } else {
            self.style = kXCDotViewStyleDefault;
        }

        self.color = event.displayColor;
    }

    return self;
}

- (id)initForMore {
    if ((self = [self init])) {
        self.style = kXCDotViewStyleMore;
        self.color = [UIColor lightGrayColor];
    }

    return self;
}

- (void)drawRect:(CGRect)rect {

    if (self.style == kXCDotViewStyleDefault) {
        [self.color set];

        CGRect insetRect = CGRectInset(rect, 1, 1);
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:insetRect];
        [path fill];
    } else if (self.style == kXCDotViewStyleSpecial) {
        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSetFillColorWithColor(context, [self.color CGColor]);

        CGSize radius = CGSizeMake(rect.size.width / 2, rect.size.height / 2);
        CGSize innerRadius = CGSizeMake(rect.size.width / 4, rect.size.height / 4);
        
        NSInteger count = 5;
        CGFloat step = 2 * M_PI / count;

        CGContextTranslateCTM(context, radius.width, radius.height);
        CGContextRotateCTM(context, -M_PI / 2);
        CGContextMoveToPoint(context, radius.width, 0);

        for (NSInteger i = 0; i < count; i++) {
            CGFloat outerStep = i * step;
            CGContextAddLineToPoint(context, radius.width * cos(outerStep), radius.height * sin(outerStep));

            CGFloat innerStep = i * step + step / 2;
            CGContextAddLineToPoint(context, innerRadius.width * cos(innerStep), innerRadius.height * sin(innerStep));
        }

        CGContextClosePath(context);
        CGContextFillPath(context);
    } else if (self.style == kXCDotViewStyleMore) {
        [self.color set];
        CGFloat thickness = 2 + 1.0 / [[UIScreen mainScreen] scale];

        CGRect insetRect = CGRectInset(rect, 1.0 / [[UIScreen mainScreen] scale], 1.0 / [[UIScreen mainScreen] scale]);
        CGRect verticalRect = CGRectMake(insetRect.origin.x + insetRect.size.width / 2 - thickness / 2, insetRect.origin.y, thickness, insetRect.size.height);
        CGRect horizontalRect = CGRectMake(insetRect.origin.x, insetRect.origin.y + insetRect.size.height / 2 - thickness / 2, insetRect.size.width, thickness);

        UIRectFill(verticalRect);
        UIRectFill(horizontalRect);
    } else {
        [NSException raise:@"XCDotViewInvalidStyleException" format:@"unknown style"];
    }
}

@end
