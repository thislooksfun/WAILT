//
//  SettingsController.m
//  WAILT
//
//  Created by thislooksfun on 8/12/14.
//  Copyright (c) 2014 thislooksfun. All rights reserved.
//

#import "SettingsController.h"
#import "AppDelegate.h"

@interface SettingsController ()

@end

@implementation SettingsController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    }
    return self;
}

- (void)initializeSettings
{
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [format setStringValue:[delegate userFormat]];
    [seperator setStringValue:[delegate seperator]];
    timeOnLeft = [delegate timeLeft];
    [timeLeft setState:timeOnLeft];
    [timeRight setState:!timeOnLeft];
    
    [writeFile setState:[delegate fileWrite]];
    [writeTime setEnabled:[delegate fileWrite]];
    [writeTime setState:[delegate fileWriteTime]];
    
    ScrollingTextView *scrolling = [delegate scrollingText];
    [scrolling setSettingsController:self];
    remaining = [scrolling getRemaining];
    [reverseTime setState:remaining];
    
    
    [title setToolTip:@"The title of the current stream\nusually a radio station"];
    [name setToolTip:@"The current song's name"];
    [artist setToolTip:@"The current song's artist"];
    [album setToolTip:@"The current song's album"];
    [time setToolTip:@"The song progress"];
    [sep setToolTip:@"The seperator - as seen below"];
    
    [self controlTextDidChange:nil];
}

- (void)windowWillClose:(NSNotification *)notification {
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [[delegate scrollingText] setSettingsController:nil];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSString *temp = [delegate getSongWithFormat:[format stringValue] andSeperator:[seperator stringValue]];
    [preview setStringValue:[[delegate scrollingText] getTime:temp andPos:timeOnLeft andRemaining:remaining]];
    
    NSString *stream = [[delegate iTunes] currentStreamTitle];
    if (stream != nil && ![stream isEqualToString:@""]) {
        [reverseTime setEnabled:false];
        [reverseTime setState:false];
        
        [remainLabel setHidden:false];
    } else {
        [reverseTime setEnabled:true];
        [reverseTime setState:remaining];
        
        [remainLabel setHidden:true];
    }
}

- (IBAction)save:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[format stringValue] forKey:@"format"];
    [defaults setObject:[seperator stringValue] forKey:@"seperator"];
    [defaults setBool:timeOnLeft forKey:@"timeOnLeft"];
    [defaults setBool:remaining forKey:@"remaining"];
    [defaults setBool:writeToFile forKey:@"writeToFile"];
    [defaults setBool:useTimeInFile forKey:@"writeTimeToFile"];
    
    delegate.userFormat = [format stringValue];
    delegate.seperator = [seperator stringValue];
    delegate.timeLeft = timeOnLeft;
    delegate.fileWrite = writeToFile;
    delegate.fileWriteTime = useTimeInFile;
    [[delegate scrollingText] setRemaining:remaining];
    
    [delegate setSong];
    [self close];
}
- (IBAction)reset:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [format setStringValue:[delegate defaultFormat]];
    [seperator setStringValue:[delegate defaultSeperator]];
    [self controlTextDidChange:nil];
}
- (IBAction)cancel:(id)sender {
    [self close];
}
- (IBAction)reverseTime:(id)sender {
    remaining = [sender state];
    [self controlTextDidChange:nil];
}
- (IBAction)timePosLeft:(id)sender {
    timeOnLeft = true;
    [self controlTextDidChange:nil];
}
- (IBAction)timePosRight:(id)sender {
    timeOnLeft = false;
    [self controlTextDidChange:nil];
}
- (IBAction)writeToFile:(id)sender {
    writeToFile = [sender state];
    [writeTime setEnabled:writeToFile];
}
- (IBAction)writeTimeToFile:(id)sender {
    useTimeInFile = [sender state];
}

@end
