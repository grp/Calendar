//
//  XCAppDelegate.m
//  Calendar
//
//  Created by Grant Paul on 12/3/12.
//  Copyright (c) 2012 Xuzz Productions, LLC. All rights reserved.
//

#import "EKEventStore+XCExtensions.h"

#import "XCRootViewController.h"
#import "XCAppDelegate.h"

@implementation XCAppDelegate

- (void)dealloc {
    [_window release];
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    EKEventStore *store = [[EKEventStore alloc] init];

    self.rootController = [[XCRootViewController alloc] initWithEventStore:store];
    [self.window setRootViewController:self.rootController];
    [self.rootController release];

    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [store refreshAllowedCalendarsCache];

                [self.rootController calendarAccessGranted];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must enable Calendar access in the Settings app." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        });
    }];

    [self.window makeKeyAndVisible];
    [self.window release];

    return YES;
}

@end
