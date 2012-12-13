//
//  XCDayViewController.m
//  Calendar
//
//  Created by Grant Paul on 12/3/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EKEventStore+XCExtensions.h"
#import "NSCalendar+XCExtensions.h"
#import "NSDate+XCExtensions.h"
#import "UIFont+XCExtensions.h"

#import "XCDayViewController.h"
#import "XCEventTableViewCell.h"
#import "XCEventCreationView.h"
#import "XCEventView.h"
#import "XCGrabHandleView.h"

#import "NSObject+XNAnimation.h"

@interface XCDayViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, XNAnimationDelegate, XCEventCreationViewDelegate>

@property (nonatomic, retain) EKEventStore *store;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSArray *events;

@property (nonatomic, retain) UILabel *dayLabel;
@property (nonatomic, retain) UILabel *dateLabel;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIView *dividerView;
@property (nonatomic, retain) XCEventCreationView *creationView;

@property (nonatomic, retain) XCGrabHandleView *grabHandle;
@property (nonatomic, retain) UIPanGestureRecognizer *grabHandlePanRecognizer;

@property (nonatomic, retain) XCEventView *expandedEventView;
@property (nonatomic, assign) CGRect expandedEventViewInitialFrame;
@property (nonatomic, retain) XCEventTableViewCell *expandedEventCell;
@property (nonatomic, assign) NSInteger expandGesturesActive;
@property (nonatomic, assign) BOOL expandOutward;

@property (nonatomic, assign) CGFloat gestureProgress;
@property (nonatomic, assign) NSInteger expandAnimationsActive;

@property (nonatomic, retain) XCEventView *createdEventView;
@property (nonatomic, retain) XCEventTableViewCell *createdEventCell;
@property (nonatomic, assign) BOOL createdEventAnimating;
@property (nonatomic, assign) CGRect createdEventEndFrame;

@end

@implementation XCDayViewController

- (id)initWithDate:(NSDate *)date events:(NSArray *)events store:(EKEventStore *)store {
    if ((self = [super init])) {
        self.store = store;
        self.date = date;
        self.events = [events sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];

        self.expandOutward = YES;
    }

    return self;
}

- (void)loadView {
    [super loadView];

    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.showsVerticalScrollIndicator = NO;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[XCEventTableViewCell class] forCellReuseIdentifier:NSStringFromClass([XCEventTableViewCell class])];

    self.tableView.layer.cornerRadius = 16.0f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.view addSubview:self.tableView];
    [self.tableView release];

    self.dividerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.dividerView.backgroundColor = [UIColor colorWithWhite:0.663 alpha:1.0f];
    [self.view addSubview:self.dividerView];
    [self.dividerView release];

    self.creationView = [[XCEventCreationView alloc] initWithStore:self.store date:self.date];
    self.creationView.delegate = self;
    [self.view addSubview:self.creationView];
    [self.creationView release];

    self.dayLabel = [[UILabel alloc] init];
    self.dayLabel.backgroundColor = [UIColor clearColor];
    self.dayLabel.font = [UIFont lightSystemFontOfSize:78.0f];
    self.dayLabel.textAlignment = NSTextAlignmentLeft;
    self.dayLabel.textColor = [UIColor colorWithWhite:0.474f alpha:1.0f];
    [self.view addSubview:self.dayLabel];
    [self.dayLabel release];

    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.font = [UIFont lightSystemFontOfSize:26.0f];
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.dateLabel.textColor = [UIColor colorWithWhite:0.663f alpha:1.0f];
    [self.view addSubview:self.dateLabel];
    [self.dateLabel release];

    self.grabHandle = [[XCGrabHandleView alloc] init];
    [self.view addSubview:self.grabHandle];
    [self.grabHandle release];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat edgeMargins = 80.0f;
    CGFloat topMargin = 200.0f;
    CGFloat innerPadding = 20.0f;

    CGFloat contentWidth = self.view.bounds.size.width - edgeMargins - edgeMargins;
    CGFloat contentHeight = self.view.bounds.size.height - topMargin - edgeMargins;
    CGFloat leftColumn = contentWidth * (3.0f / 5.0f) - innerPadding;
    CGFloat rightColumn = contentWidth * (2.0f / 5.0f) - innerPadding;

    CGRect tableFrame = CGRectZero;
    tableFrame.origin.x = edgeMargins;
    tableFrame.origin.y = topMargin;
    tableFrame.size.width = leftColumn;
    tableFrame.size.height = contentHeight;
    self.tableView.frame = tableFrame;
    
    CGRect dividerFrame = CGRectZero;
    dividerFrame.origin.x = edgeMargins + leftColumn + innerPadding - (1.0 / [[UIScreen mainScreen] scale]);
    dividerFrame.origin.y = topMargin;
    dividerFrame.size.width = 1.0f;
    dividerFrame.size.height = contentHeight;
    self.dividerView.frame = dividerFrame;

    CGRect creationFrame = CGRectZero;
    creationFrame.origin.x = edgeMargins + leftColumn + innerPadding + innerPadding;
    creationFrame.origin.y = topMargin;
    creationFrame.size.width = rightColumn;
    creationFrame.size.height = contentHeight;
    self.creationView.frame = creationFrame;

    CGRect handleFrame = CGRectZero;
    handleFrame.size.width = 80.0f;
    handleFrame.size.height = 50.0f;
    handleFrame.origin.x = edgeMargins + contentWidth - handleFrame.size.width;
    handleFrame.origin.y = (topMargin - handleFrame.size.height) / 2 + 10.0f;
    self.grabHandle.frame = handleFrame;

    self.dayLabel.frame = CGRectMake(edgeMargins, 30, self.view.bounds.size.width - edgeMargins * 2, 130);
    self.dateLabel.frame = CGRectMake(edgeMargins, 135, self.view.bounds.size.width - edgeMargins * 2, 40);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dayLabel.text = self.date.weekdayName;
    self.dateLabel.text = self.date.dateName;
}

- (void)setDelegate:(id<XCDayViewControllerDelegate>)delegate {
    _delegate = delegate;

    self.grabHandlePanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFromGrabHandleRecognizer:)];
    self.grabHandlePanRecognizer.delegate = self;
    UIView *view = [self.delegate dayViewController:self viewForGestureRecognizer:self.grabHandlePanRecognizer];
    [view addGestureRecognizer:self.grabHandlePanRecognizer];
    [self.grabHandlePanRecognizer release];
}

- (void)panFromGrabHandleRecognizer:(UIPanGestureRecognizer *)recognizer {
    UIGestureRecognizerState state = recognizer.state;

    if (state == UIGestureRecognizerStateBegan) {
        if (!CGRectContainsPoint(self.grabHandle.frame, [recognizer locationInView:self.view])) {
            recognizer.enabled = NO;
            recognizer.enabled = YES;
            return;
        }
    }
    
    if (state != UIGestureRecognizerStateCancelled) {
        [self.delegate dayViewController:self panFromGestureRecognizer:recognizer];
    }
}

- (void)extractEventView:(XCEventView *)eventView fromCell:(XCEventTableViewCell *)cell {
    self.expandedEventView = eventView;
    self.expandedEventCell = cell;
    self.expandedEventViewInitialFrame = [self.view convertRect:self.expandedEventView.frame fromView:self.expandedEventCell];

    eventView.collapsedHeight = self.expandedEventViewInitialFrame.size.height;
    eventView.expanded = YES;
    
    eventView.frame = self.expandedEventViewInitialFrame;
    [self.view addSubview:self.expandedEventView];

    self.tableView.scrollEnabled = NO;
}

- (void)replaceEventView {
    self.expandedEventView.transform = CGAffineTransformIdentity;
    self.expandedEventView.frame = [self.view convertRect:self.expandedEventViewInitialFrame toView:self.expandedEventCell];
    [self.expandedEventCell addSubview:self.expandedEventView];
    [self.expandedEventCell setNeedsLayout];

    self.expandedEventView.expanded = NO;

    self.expandedEventView = nil;
    self.expandedEventCell = nil;

    self.tableView.scrollEnabled = YES;
}

- (void)animationStarted:(XNAnimation *)animation {
    if (!self.createdEventAnimating) {
        self.expandAnimationsActive += 1;
    }
}

- (void)animationStopped:(XNAnimation *)animation {
    if (!self.createdEventAnimating) {
        self.expandAnimationsActive -= 1;

        if (self.expandAnimationsActive == 0) {
            if (!self.expandOutward) {
                [self replaceEventView];
            } else {
                self.expandedEventView.interactive = YES;
            }

            self.expandOutward = !self.expandOutward;
        }
    } else {
        self.createdEventAnimating = NO;
        self.tableView.scrollEnabled = YES;

        if (self.expandedEventView != self.createdEventView) {
            self.createdEventView.frame = [self.view convertRect:self.createdEventEndFrame toView:self.createdEventCell];
            [self.createdEventCell addSubview:self.createdEventView];
        }

        self.createdEventEndFrame = CGRectZero;
        self.createdEventCell = nil;
        self.createdEventView = nil;
    }
}

- (void)setGestureProgress:(CGFloat)gestureProgress {
    _gestureProgress = gestureProgress;

    CGFloat initialHeight = (self.expandOutward ? self.expandedEventViewInitialFrame.size.height : self.tableView.bounds.size.height);
    CGFloat endHeight = (self.expandOutward ? self.tableView.bounds.size.height : self.expandedEventViewInitialFrame.size.height);

    CGRect bounds = self.expandedEventView.bounds;
    bounds.size.height = initialHeight + self.gestureProgress * (endHeight - initialHeight);
    bounds.size.height = (bounds.size.height < 0 ? 0 : bounds.size.height);
    self.expandedEventView.bounds = bounds;

    self.tableView.alpha = self.expandOutward ? (1.0 - self.gestureProgress) : self.gestureProgress;
}

- (void)startGestureInView:(UIView *)view {
    [self.expandedEventView removeAllXNAnimations];
    [view removeAllXNAnimations];
    [self removeAllXNAnimations];

    if (self.expandOutward) {
        XCEventView *eventView = (XCEventView *) view;
        XCEventTableViewCell *cell = (XCEventTableViewCell *) view.superview;
        [self extractEventView:eventView fromCell:cell];
    }

    self.expandedEventView.interactive = NO;

    [self setGestureProgress:0];
}

- (void)toggleExpandedView:(XCEventView *)view {
    [self startGestureInView:view];
    [self finishGestureWithVelocity:0];
}

- (void)finishGestureWithVelocity:(CGFloat)velocity {
    self.expandGesturesActive -= 1;

    if (velocity < 0) {
        self.expandOutward = !self.expandOutward;
        velocity = -velocity;
        self.gestureProgress = 1.0 - self.gestureProgress;
    }

    XNAnimation *progressAnimation = [XNAnimation animationWithKeyPath:@"gestureProgress"];
    progressAnimation.timingFunction = [XNSpringTimingFunction timingFunction];
    progressAnimation.velocity = [NSNumber numberWithFloat:velocity];
    progressAnimation.fromValue = [NSNumber numberWithFloat:self.gestureProgress];
    progressAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    progressAnimation.delegate = self;
    [self addXNAnimation:progressAnimation];

    CGPoint to = CGPointZero;

    if (self.expandOutward) {
        to = self.tableView.layer.position;
    } else {
        to = CGPointMake(CGRectGetMidX(self.expandedEventViewInitialFrame), CGRectGetMidY(self.expandedEventViewInitialFrame));
    }

    CGFloat endHeight = (self.expandOutward ? self.tableView.bounds.size.height : self.expandedEventViewInitialFrame.size.height);

    XNAnimation *centerAnimation = [XNAnimation animationWithKeyPath:@"center"];
    centerAnimation.timingFunction = [XNSpringTimingFunction timingFunction];
    centerAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(0, velocity * endHeight)];
    centerAnimation.toValue = [NSValue valueWithCGPoint:to];
    centerAnimation.delegate = self;
    [self.expandedEventView addXNAnimation:centerAnimation];
}

- (void)pinchFromRecognizer:(UIPinchGestureRecognizer *)recognizer {
    UIGestureRecognizerState state = [recognizer state];

    CGFloat initialHeight = (self.expandOutward ? self.expandedEventViewInitialFrame.size.height : self.tableView.bounds.size.height);
    CGFloat endHeight = (self.expandOutward ? self.tableView.bounds.size.height : self.expandedEventViewInitialFrame.size.height);
    CGFloat endScale = (endHeight / initialHeight);

    CGFloat scale = recognizer.scale;
    CGFloat velocity = recognizer.velocity;
    CGFloat percentage = 0.0;
    CGFloat percentageVelocity = 0.0f;

    if (self.expandOutward) {
        percentage = (scale - 1) / endScale;
        percentageVelocity = (velocity - 1) / endScale;
    } else {
        percentage = (1 - scale) / (1 - endScale);
        percentageVelocity = (1 - velocity) / (1 - endScale);
    }

    if (state == UIGestureRecognizerStateBegan) {
        [self startGestureInView:recognizer.view];
    } else if (state == UIGestureRecognizerStateChanged) {

        [self setGestureProgress:percentage];
    } else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        [self finishGestureWithVelocity:percentageVelocity];
    }
}

- (void)panFromRecognizer:(UIPanGestureRecognizer *)recognizer {
    UIGestureRecognizerState state = [recognizer state];

    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self.view];
        NSValue *translationValue = [NSValue valueWithCGPoint:translation];

        [self.expandedEventView.layer setValue:translationValue forKeyPath:@"transform.translation"];
    } else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        CGPoint to = CGPointZero;
        NSValue *toValue = [NSValue valueWithCGPoint:to];

        XNAnimation *animation = [XNAnimation animationWithKeyPath:@"transform.translation"];
        animation.timingFunction = [XNSpringTimingFunction timingFunction];
        animation.velocity = [NSValue valueWithCGPoint:[recognizer velocityInView:self.view]];
        animation.toValue = toValue;
        animation.delegate = self;
        [self.expandedEventView addXNAnimation:animation];
    }
}

- (void)rotateFromRecognizer:(UIRotationGestureRecognizer *)recognizer {
    UIGestureRecognizerState state = [recognizer state];

    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        [self.expandedEventView.layer setValue:[NSNumber numberWithFloat:recognizer.rotation] forKeyPath:@"transform.rotation"];
    } else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        CGFloat to = 0;
        NSNumber *toValue = [NSNumber numberWithFloat:to];

        XNAnimation *animation = [XNAnimation animationWithKeyPath:@"transform.rotation"];
        animation.timingFunction = [XNSpringTimingFunction timingFunction];
        animation.velocity = [NSNumber numberWithFloat:recognizer.velocity];
        animation.toValue = toValue;
        animation.delegate = self;
        [self.expandedEventView addXNAnimation:animation];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)eventCreationView:(XCEventCreationView *)creationView panFromRecognizer:(UIPanGestureRecognizer *)recognizer {
    UIGestureRecognizerState state = [recognizer state];

    CGPoint translation = [recognizer translationInView:self.view];

    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        NSValue *translationValue = [NSValue valueWithCGPoint:translation];

        [self.createdEventView.layer setValue:translationValue forKeyPath:@"transform.translation"];
    } else if (state == UIGestureRecognizerStateEnded) {
        [self.createdEventView removeAllXNAnimations];

        CGRect frame = self.createdEventView.frame;
        self.createdEventView.transform = CGAffineTransformIdentity;
        self.createdEventView.frame = frame;

        CGRect to = self.createdEventEndFrame;
        NSValue *toValue = [NSValue valueWithCGRect:to];

        CGPoint v = [recognizer velocityInView:self.view];
        CGRect velocity = CGRectMake(v.x, v.y, v.x, v.y);
        NSValue *velocityValue = [NSValue valueWithCGRect:velocity];

        self.createdEventAnimating = YES;
        self.tableView.scrollEnabled = NO;

        XNAnimation *animation = [XNAnimation animationWithKeyPath:@"frame"];
        animation.timingFunction = [XNSpringTimingFunction timingFunction];
        animation.velocity = velocityValue;
        animation.toValue = toValue;
        animation.delegate = self;
        [self.createdEventView addXNAnimation:animation];
    }
}

- (UIView *)eventCreationView:(XCEventCreationView *)creationView viewForGestureRecognizer:(UIGestureRecognizer *)recognizer {
    return self.view;
}

- (void)eventCreationView:(XCEventCreationView *)creationView createdEvent:(EKEvent *)event fromRect:(CGRect)rect recognizer:(UIPanGestureRecognizer *)recognizer {
    [creationView reset];

    [self.store saveEvent:event span:EKSpanThisEvent commit:YES error:nil];

    if (self.expandedEventView != nil) {
        [self toggleExpandedView:self.expandedEventView];
    }

    NSInteger row = [self.events indexOfObject:event inSortedRange:NSMakeRange(0, self.events.count) options:NSBinarySearchingInsertionIndex usingComparator:^(EKEvent *a, EKEvent *b) {
        return [a compareStartDateWithEvent:b];
    }];
    
    NSMutableArray *events = [[self.events mutableCopy] autorelease];
    events = events ?: [NSMutableArray array];
    [events insertObject:event atIndex:row];
    self.events = [[events copy] autorelease];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];

    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];

    XCEventTableViewCell *cell = (XCEventTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    XCEventView *eventView = cell.eventView;

    self.createdEventView = eventView;
    self.createdEventCell = cell;
    self.createdEventEndFrame = [self.view convertRect:eventView.frame fromView:cell];
    
    CGRect frame = [self.view convertRect:rect fromView:self.creationView];
    eventView.frame = frame;
    [self.view addSubview:eventView];

    CGPoint v = [recognizer velocityInView:self.view];
    CGPoint c = [recognizer translationInView:self.view];

    // yeah this should use new variables...
    rect.origin.x = 0;
    rect = [self.view convertRect:rect fromView:self.creationView];
    c.x += CGRectGetMidX(rect);
    c.y += CGRectGetMidY(rect);

    XNAnimation *animation = [XNAnimation animationWithKeyPath:@"center"];
    animation.timingFunction = [XNSpringTimingFunction timingFunctionWithTension:273 damping:15 mass:1.0];
    animation.velocity = [NSValue valueWithCGPoint:v];
    animation.toValue = [NSValue valueWithCGPoint:c];
    [eventView addXNAnimation:animation];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([XCEventTableViewCell class]) forIndexPath:indexPath];

    cell.padding = 12.0f;
    [cell updateWithEvent:self.events[indexPath.row]];
    cell.eventView.margin = 24.0f;

    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFromRecognizer:)];
    [pinchRecognizer setDelegate:self];
    [cell.eventView addGestureRecognizer:pinchRecognizer];
    [pinchRecognizer release];

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFromRecognizer:)];
    [panRecognizer setDelegate:self];
    [panRecognizer setMinimumNumberOfTouches:2];
    [cell.eventView addGestureRecognizer:panRecognizer];
    [panRecognizer release];

    UIRotationGestureRecognizer *rotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateFromRecognizer:)];
    [rotateRecognizer setDelegate:self];
    [cell.eventView addGestureRecognizer:rotateRecognizer];
    [rotateRecognizer release];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XCEventTableViewCell *cell = (XCEventTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    XCEventView *eventView = cell.eventView;
    cell.highlighted = NO;

    [self toggleExpandedView:eventView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.delegate dayViewControllerWantsRepresentAfterRotation:self];
}

@end
