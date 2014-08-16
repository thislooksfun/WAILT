//
//  AppDelegate.h
//  NowPlaying
//
//  Created by thislooksfun on 7/14/14.
//  Copyright (c) 2014 thislooksfun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"
#import "ScrollingTextView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
}

@property (strong) IBOutlet NSMenu *statusMenu;
@property (strong) IBOutlet ScrollingTextView *scrollingText;
@property (strong) NSStatusItem *statusBar;
@property iTunesApplication *iTunes;
@property NSString *currentData;
@property NSString *defaultFormat;
@property NSString *defaultSeparator;
@property NSString *defaultTimeFormat;
@property NSString *userFormat;
@property NSString *Separator;
@property NSString *timeFormat;
@property BOOL timeLeft;
@property BOOL fileWrite;
@property BOOL fileWriteTime;

- (void) onClick;
- (void) setSong;
- (NSString *) getSongWithFormat:(NSString *)form andSeparator:(NSString *)sep;

@end
