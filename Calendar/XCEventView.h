//
//  XCEventView.h
//  Calendar
//
//  Created by Grant Paul on 12/7/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

#import "XCBaseEventView.h"

@interface XCEventView : XCBaseEventView

- (id)initWithEvent:(EKEvent *)event;

@property (nonatomic, retain) EKEvent *event;

@end
