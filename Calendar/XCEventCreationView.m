//
//  XCEventCreationView.m
//  Calendar
//
//  Created by Grant Paul on 12/7/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NSDateComponents+XCExtensions.h"
#import "NSCalendar+XCExtensions.h"
#import "NSDate+XCExtensions.h"
#import "EKEvent+XCExtensions.h"
#import "UIFont+XCExtensions.h"

#import "NSObject+XNAnimation.h"

#import "XCEventCreationView.h"
#import "XCBaseEventView.h"

@interface XCEventCreationTextField : UITextField
@end

@interface XCEventCreationView () <UITextFieldDelegate, UITextViewDelegate, XNAnimationDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, retain) EKEventStore *store;
@property (nonatomic, copy) NSDate *date;

@property (nonatomic, retain) XCEventCreationTextField *titleField;
@property (nonatomic, retain) XCEventCreationTextField *locationField;
@property (nonatomic, retain) UITextView *notesTextView;
@property (nonatomic, retain) XCBaseEventView *eventView;

@property (nonatomic, assign) BOOL gestureActive;
@property (nonatomic, retain) UIPanGestureRecognizer *panRecognizer;

@end

@implementation XCEventCreationTextField

- (void)drawPlaceholderInRect:(CGRect)rect {
    CGFloat white, alpha;
    [self.textColor getWhite:&white alpha:&alpha];
    white *= 1.5f;
    [[UIColor colorWithWhite:white alpha:alpha] setFill];

    [[self placeholder] drawInRect:rect withFont:self.font];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 8.0f, 4.0f);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 8.0f, 4.0f);
}

@end

@implementation XCEventCreationView

- (EKEvent *)eventForCurrentState {
    EKEvent *event = [EKEvent eventWithEventStore:self.store];
    event.title = self.titleField.text;
    event.notes = self.notesTextView.text;
    event.location = self.locationField.text;
    event.allDay = YES;
    event.startDate = event.endDate = self.date;
    return event;
}

- (BOOL)hasContent {
    BOOL title = (self.titleField.text.length != 0);

    return title;
}

- (void)updateHiddenState {
    BOOL content = self.hasContent;

    if (!content) {
        self.eventView.backgroundColor = [UIColor clearColor];
        self.eventView.layer.borderColor = [[UIColor colorWithWhite:0.60f alpha:1.0f] CGColor];
        self.eventView.layer.borderWidth = 1.0f;
    } else {
        EKXCEventDueDate dueDate = [EKEvent dueDateForStartDate:self.date endDate:self.date allDay:YES];
        self.eventView.backgroundColor = [EKEvent displayColorForCompleted:NO dueDate:dueDate];
        self.eventView.layer.borderColor = NULL;
        self.eventView.layer.borderWidth = 0;
    }
}

- (void)setDelegate:(id<XCEventCreationViewDelegate>)delegate {
    _delegate = delegate;

    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFromRecognizer:)];
    self.panRecognizer.delegate = self;
    self.panRecognizer.maximumNumberOfTouches = 1;
    self.panRecognizer.minimumNumberOfTouches = 1;
    UIView *gestureView = [self.delegate eventCreationView:self viewForGestureRecognizer:self.panRecognizer];
    [gestureView addGestureRecognizer:self.panRecognizer];
    [self.panRecognizer release];
}

- (void)reset {
    self.titleField.text = nil;
    self.locationField.text = nil;
    self.notesTextView.text = nil;

    [self.eventView removeFromSuperview];
    self.eventView = [[XCBaseEventView alloc] init];
    self.eventView.margin = 24.0f;
    [self addSubview:self.eventView];
    [self.eventView release];

    [self updateHiddenState];
}

- (void)textViewDidChange:(UITextView *)textView {
    self.eventView.notes = textView.text;
    [self updateHiddenState];
}

- (void)textFieldDidChange:(UITextField *)textField {
    self.eventView.title = textField.text;
    [self updateHiddenState];
}

- (void)locationFieldDidChange:(UITextField *)locationField {
    self.eventView.location = locationField.text;
    [self updateHiddenState];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.locationField) {
        [self.notesTextView becomeFirstResponder];
    } else if (textField == self.titleField) {
        [self.locationField becomeFirstResponder];
    }

    return NO;
}

- (void)animationStopped:(XNAnimation *)animation {
    self.gestureActive = NO;
}

- (void)panFromRecognizer:(UIPanGestureRecognizer *)recognizer {
    UIGestureRecognizerState state = recognizer.state;

    if (state == UIGestureRecognizerStateBegan) {
        if (!CGRectContainsPoint(self.eventView.frame, [recognizer locationInView:self]) || !self.hasContent) {
            recognizer.enabled = NO;
            recognizer.enabled = YES;
            return;
        }

        self.gestureActive = YES;
    }

    if (self.gestureActive) {
        CGFloat translation = [recognizer translationInView:self].x;

        if (translation > 0) {
            translation *= 0.25f;
        } else {
            translation *= 0.50f;
        }

        if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
            self.gestureActive = YES;

            [self.eventView removeAllXNAnimations];

            NSValue *translationValue = [NSNumber numberWithFloat:translation];
            [self.eventView.layer setValue:translationValue forKeyPath:@"transform.translation.x"];

            if (-translation > self.eventView.bounds.size.width * (2.0f / 5.0f)) {
                EKEvent *event = [self eventForCurrentState];
                [self.delegate eventCreationView:self createdEvent:event fromRect:self.eventView.frame recognizer:recognizer];

                [recognizer setTranslation:CGPointZero inView:recognizer.view];

                self.gestureActive = NO;
            }
        } else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
            XNAnimation *resetAnimation = [XNAnimation animationWithKeyPath:@"transform.translation.x"];
            resetAnimation.timingFunction = [XNSpringTimingFunction timingFunction];
            resetAnimation.delegate = self;
            resetAnimation.velocity = [NSNumber numberWithFloat:[recognizer velocityInView:self].x];
            resetAnimation.toValue = [NSNumber numberWithFloat:0];
            [self.eventView addXNAnimation:resetAnimation];
        }
    } else if (state != UIGestureRecognizerStateCancelled) {
        [self.delegate eventCreationView:self panFromRecognizer:recognizer];
    }
}

- (id)initWithStore:(EKEventStore *)store date:(NSDate *)date {
    if ((self = [super init])) {
        self.store = store;
        self.date = date;

        self.titleField = [[XCEventCreationTextField alloc] init];
        self.titleField.delegate = self;
        [self.titleField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.titleField.placeholder = @"Title";
        self.titleField.textColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
        self.titleField.textAlignment = NSTextAlignmentLeft;
        self.titleField.font = [UIFont lightSystemFontOfSize:32.0f];
        self.titleField.layer.borderColor = [[UIColor colorWithWhite:0.65f alpha:1.0f] CGColor];
        self.titleField.layer.borderWidth = 1.0f;
        self.titleField.returnKeyType = UIReturnKeyNext;
        [self addSubview:self.titleField];
        [self.titleField release];

        self.locationField = [[XCEventCreationTextField alloc] init];
        self.locationField.delegate = self;
        [self.locationField addTarget:self action:@selector(locationFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.locationField.placeholder = @"Location";
        self.locationField.textColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
        self.locationField.textAlignment = NSTextAlignmentLeft;
        self.locationField.font = [UIFont lightSystemFontOfSize:32.0f];
        self.locationField.layer.borderColor = [[UIColor colorWithWhite:0.65f alpha:1.0f] CGColor];
        self.locationField.layer.borderWidth = 1.0f;
        self.locationField.returnKeyType = UIReturnKeyNext;
        [self addSubview:self.locationField];
        [self.locationField release];

        self.notesTextView = [[UITextView alloc] init];
        self.notesTextView.delegate = self;
        self.notesTextView.textColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
        self.notesTextView.textAlignment = NSTextAlignmentLeft;
        self.notesTextView.font = [UIFont lightSystemFontOfSize:24.0f];
        self.notesTextView.layer.borderColor = [[UIColor colorWithWhite:0.65f alpha:1.0f] CGColor];
        self.notesTextView.layer.borderWidth = 1.0f;
        self.notesTextView.returnKeyType = UIReturnKeyDefault;
        [self addSubview:self.notesTextView];
        [self.notesTextView release];

        [self reset];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat padding = 16.0f;

    if (!self.gestureActive) {
        self.titleField.frame = CGRectMake(0, 0, self.bounds.size.width, 48);
        self.locationField.frame = CGRectMake(0, CGRectGetMaxY(self.titleField.frame) + padding, self.bounds.size.width, 48);

        self.eventView.frame = CGRectMake(0, self.bounds.size.height - 98.0f, self.bounds.size.width, 98.0f);

        self.notesTextView.frame = CGRectMake(0, CGRectGetMaxY(self.locationField.frame) + padding, self.bounds.size.width, self.bounds.size.height - CGRectGetMaxY(self.locationField.frame) - padding - CGRectGetHeight(self.eventView.frame) - padding);
    }
}

@end
