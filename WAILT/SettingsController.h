//
//  SettingsController.h
//  WAILT
//
//  Created by thislooksfun on 8/12/14.
//  Copyright (c) 2014 thislooksfun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SettingsController : NSWindowController {
    @private
    IBOutlet NSTextField *format;
    IBOutlet NSTextField *separator;
    IBOutlet NSTextField *preview;
    IBOutlet NSButton *reverseTime;
    IBOutlet NSButton *writeFile;
    IBOutlet NSButton *writeTime;
    
    IBOutlet NSTextField *title;
    IBOutlet NSTextField *name;
    IBOutlet NSTextField *artist;
    IBOutlet NSTextField *album;
    IBOutlet NSTextField *time;
    IBOutlet NSTextField *sep;
    IBOutlet NSTextField *remainLabel;
    
    IBOutlet NSCell *timeLeft;
    IBOutlet NSCell *timeRight;
    
    bool remaining;
    bool timeOnLeft;
    bool writeToFile;
    bool useTimeInFile;
}

- (void)initializeSettings;
- (IBAction)save:(id)sender;
- (IBAction)reset:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)reverseTime:(id)sender;
- (IBAction)writeToFile:(id)sender;
- (IBAction)writeTimeToFile:(id)sender;
- (void)controlTextDidChange:(NSNotification *)notification;

@end
