//
//  XCBaseEventView.h
//  Calendar
//
//  Created by Grant Paul on 12/9/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface XCBaseEventView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *notes;

@property (nonatomic, assign) CGFloat margin;

@property (nonatomic, assign) CGFloat collapsedHeight;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, assign, getter=isInteractive) BOOL interactive;

@end
