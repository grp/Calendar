//
//  XCEventCreationView.h
//  Calendar
//
//  Created by Grant Paul on 12/7/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@class XCEventView;
@protocol XCEventCreationViewDelegate;

@interface XCEventCreationView : UIView

- (id)initWithStore:(EKEventStore *)store date:(NSDate *)date;

@property (nonatomic, assign) id<XCEventCreationViewDelegate> delegate;

- (void)reset;

@end

@protocol XCEventCreationViewDelegate <NSObject>

- (UIView *)eventCreationView:(XCEventCreationView *)creationView viewForGestureRecognizer:(UIGestureRecognizer *)recognizer;
- (void)eventCreationView:(XCEventCreationView *)creationView createdEvent:(EKEvent *)event fromRect:(CGRect)rect recognizer:(UIPanGestureRecognizer *)recognizer;
- (void)eventCreationView:(XCEventCreationView *)creationView panFromRecognizer:(UIPanGestureRecognizer *)recognizer;

@end
