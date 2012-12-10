//
//  XCEventTableViewCell.h
//  Calendar
//
//  Created by Grant Paul on 12/7/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@class XCEventView;

@interface XCEventTableViewCell : UITableViewCell

@property (nonatomic, retain, readonly) XCEventView *eventView;
@property (nonatomic, assign) CGFloat padding;

- (void)updateWithEvent:(EKEvent *)event;

@end
