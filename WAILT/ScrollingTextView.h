//ScrollingTextView.h:
//Adapted from http://stackoverflow.com/a/3233802/3438793

#import <Cocoa/Cocoa.h>
#import "iTunes.h"
@class SettingsController;

@interface ScrollingTextView : NSView<NSMenuDelegate> {
    NSTimeInterval speed;
    NSTimer *scroller;
    NSPoint point;
    NSString *text;
    CGFloat stringWidth;
    NSInteger delay;
    NSDictionary *fontDictBlack;
    NSDictionary *fontDictWhite;
    NSDictionary *fontDict;
    NSFont *font;
    BOOL isBigger;
    BOOL draw;
    BOOL isMenuShowing;
    BOOL remaining;
    SettingsController *settings;
}

@property iTunesApplication *iTunes;
@property (nonatomic) NSTimeInterval speed;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *formattedText;
@property (nonatomic) NSInteger delay;
@property (nonatomic) NSDictionary *fontDictBlack;
@property (nonatomic) NSDictionary *fontDictWhite;
@property (nonatomic) NSDictionary *fontDict;
@property (nonatomic) NSFont *font;
@property (strong, nonatomic) NSStatusItem *enclosingMenu;

- (void) setSettingsController:(SettingsController *) controller;
- (void) setRemaining:(BOOL) rev;
- (BOOL) getRemaining;
- (NSString *) getTime:(NSString *)inp andPos:(BOOL) onLeft andRemaining:(BOOL) remain;

@end