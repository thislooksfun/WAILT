//
//  MenuController.h
//  WAILT
//
//  Created by thislooksfun on 8/11/14.
//  Copyright (c) 2014 thislooksfun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SettingsController;

@interface MenuController : NSObject

@property (strong, nonatomic) SettingsController *settingsController;

- (IBAction)about:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)options:(id)sender;

@end
