//
//  XCDotView.h
//  Calendar
//
//  Created by Grant Paul on 12/4/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface XCDotView : UIView

- (id)initWithEvent:(EKEvent *)event;
- (id)initForMore;

@property (nonatomic, retain) UIColor *color;

@end
