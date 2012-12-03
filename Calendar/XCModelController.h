//
//  XCModelController.h
//  Calendar
//
//  Created by Grant Paul on 12/3/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XCDataViewController;

@interface XCModelController : NSObject <UIPageViewControllerDataSource>

- (XCDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(XCDataViewController *)viewController;

@end
