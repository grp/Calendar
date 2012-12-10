//
//  XCHeaderCollectionViewCell.m
//  Calendar
//
//  Created by Grant Paul on 12/4/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIFont+XCExtensions.h"

#import "XCHeaderCollectionViewCell.h"

@interface XCHeaderCollectionViewCell ()

@property (nonatomic, retain) UILabel *headerLabel;

@end

@implementation XCHeaderCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];

        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.contentView.bounds, 1, 1)];
        self.headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.headerLabel.adjustsLetterSpacingToFitWidth = YES;
        self.headerLabel.adjustsFontSizeToFitWidth = YES;
        self.headerLabel.numberOfLines = 1;
        self.headerLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.headerLabel.font = [UIFont lightSystemFontOfSize:16.0f];
        self.headerLabel.textColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
        self.headerLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.headerLabel];
        [self.headerLabel release];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    [_title release];
    _title = [title copy];

    self.headerLabel.text = self.title;
}

@end
