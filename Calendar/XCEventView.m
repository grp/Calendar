//
//  XCEventView.m
//  Calendar
//
//  Created by Grant Paul on 12/7/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "NSDateComponents+XCExtensions.h"
#import "NSCalendar+XCExtensions.h"
#import "NSDate+XCExtensions.h"
#import "EKEvent+XCExtensions.h"
#import "EKEventStore+XCExtensions.h"
#import "UIFont+XCExtensions.h"

#import "XCEventView.h"

@interface XCEventView ()

@end

@implementation XCEventView

- (void)setEvent:(EKEvent *)event {
    [_event release];
    _event = [event retain];

    self.title = self.event.displayTitle;
    self.notes = self.event.notes;
    self.location = self.event.location;
    self.backgroundColor = self.event.displayColor;
}

- (id)initWithEvent:(EKEvent *)event {
    if ((self = [super init])) {
        self.event = event;
    }
    
    return self;
}

@end
