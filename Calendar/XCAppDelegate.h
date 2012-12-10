//
//  XCAppDelegate.h
//  Calendar
//
//  Created by Grant Paul on 12/3/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@class XCRootViewController;

@interface XCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) XCRootViewController *rootController;

@end
