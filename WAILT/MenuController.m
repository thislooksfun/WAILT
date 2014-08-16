//
//  MenuController.m
//  WAILT
//
//  Created by thislooksfun on 8/11/14.
//  Copyright (c) 2014 thislooksfun. All rights reserved.
//

#import "MenuController.h"
#import "SettingsController.h"

@implementation MenuController
@synthesize settingsController;

- (IBAction)about:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:nil];
}
- (IBAction)quit:(id)sender {
    [NSApp terminate:self];
}
- (IBAction)options:(id)sender {
    if (!settingsController) {
        settingsController = [[SettingsController alloc] initWithWindowNibName:@"Settings"];
    }
    
    [NSApp activateIgnoringOtherApps:YES];
    [settingsController showWindow:nil];
    [settingsController initializeSettings];
}

@end