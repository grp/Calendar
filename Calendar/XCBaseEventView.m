//
//  XCBaseEventView.m
//  Calendar
//
//  Created by Grant Paul on 12/9/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//


#import "NSDateComponents+XCExtensions.h"
#import "NSCalendar+XCExtensions.h"
#import "NSDate+XCExtensions.h"
#import "EKEvent+XCExtensions.h"
#import "EKEventStore+XCExtensions.h"
#import "UIFont+XCExtensions.h"

#import "XCBaseEventView.h"

@interface XCBaseEventView ()

@property (nonatomic, retain, readwrite) EKEvent *event;

@property (nonatomic, assign) CGFloat expandedHeight;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *classLabel;
@property (nonatomic, retain) UITextView *descriptionView;

@end

@implementation XCBaseEventView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.margin = 15.0f;

        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.titleLabel];
        [self.titleLabel release];

        self.classLabel = [[UILabel alloc] init];
        self.classLabel.backgroundColor = [UIColor clearColor];
        self.classLabel.textColor = [UIColor whiteColor];
        self.classLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.classLabel];
        [self.classLabel release];

        self.descriptionView = [[UITextView alloc] init];
        self.descriptionView.backgroundColor = [UIColor clearColor];
        self.descriptionView.textColor = [UIColor whiteColor];
        self.descriptionView.editable = NO;
        self.descriptionView.textAlignment = NSTextAlignmentLeft;
        self.descriptionView.contentInset = UIEdgeInsetsMake(-4, -8, -8, -4);
        [self addSubview:self.descriptionView];
        [self.descriptionView release];

        self.expanded = NO;
        self.interactive = NO;
    }

    return self;
}

- (void)setTitle:(NSString *)title {
    [_title release];
    _title = [title copy];

    self.titleLabel.text = self.title;
}

- (void)setLocation:(NSString *)location {
    [_location release];
    _location = [location copy];

    self.classLabel.text = self.location;
}

- (void)setNotes:(NSString *)notes {
    [_notes release];
    _notes = [notes copy];

    self.descriptionView.text = self.notes;
}

- (void)setMargin:(CGFloat)margin {
    _margin = margin;

    [self setNeedsLayout];
}

- (void)setInteractive:(BOOL)interactive {
    _interactive = interactive;

    self.descriptionView.scrollEnabled = self.interactive;
    self.descriptionView.userInteractionEnabled = self.interactive;
}

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;

    if (self.expanded) {
        self.collapsedHeight = self.bounds.size.height;
    }

    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat margin = self.margin;
    self.layer.cornerRadius = margin * (2.0f / 3.0f);

    CGFloat headerHeight = self.bounds.size.height;

    if (self.expanded) {
        headerHeight = self.collapsedHeight;
    }

    CGFloat contentHeight = headerHeight - margin - margin;
    CGFloat contentWidth = self.bounds.size.width - margin - margin;

    UIFont *ratioFont = [UIFont lightSystemFontOfSize:12.0f];
    CGFloat fontRatio = ratioFont.pointSize / (ratioFont.capHeight - ratioFont.descender);

    self.titleLabel.font = [UIFont lightSystemFontOfSize:contentHeight * 0.6 * fontRatio];
    self.classLabel.font = [UIFont lightSystemFontOfSize:contentHeight * 0.4 * fontRatio];

    self.titleLabel.frame = CGRectMake(margin, margin + (self.titleLabel.font.capHeight - self.titleLabel.font.ascender), contentWidth, self.titleLabel.font.ascender - self.titleLabel.font.descender);
    self.classLabel.frame = CGRectMake(margin, CGRectGetMaxY(self.titleLabel.frame), contentWidth, self.classLabel.font.ascender - self.classLabel.font.descender);

    CGRect descriptionFrame = CGRectZero;
    descriptionFrame.origin.x = margin;
    descriptionFrame.origin.y = headerHeight;
    descriptionFrame.size.width = contentWidth;

    if (self.expanded) {
        descriptionFrame.size.height = self.bounds.size.height - descriptionFrame.origin.y - margin;
        descriptionFrame.size.height = (descriptionFrame.size.height < 0 ? 0 : descriptionFrame.size.height);
    } else {
        descriptionFrame.size.height = 0;
    }

    self.descriptionView.font = [UIFont lightSystemFontOfSize:18.0f];
    self.descriptionView.frame = descriptionFrame;
}

@end
