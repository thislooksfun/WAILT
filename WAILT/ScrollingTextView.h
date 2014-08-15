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
    NSString *tempText;
    NSString *nextText;
    CGFloat stringWidth;
    NSInteger delay;
    NSDictionary *fontDictBlack;
    NSDictionary *fontDictWhite;
    NSDictionary *fontDict;
    NSFont *font;
    CGFloat nextWidth;
    CGFloat nextSize;
    BOOL isBigger;
    BOOL nextIsBigger;
    BOOL draw;
    BOOL isMenuShowing;
    BOOL shouldShrink;
    BOOL remaining;
    SettingsController *settings;
}

@property iTunesApplication *iTunes;
@property (nonatomic) NSTimeInterval speed;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *formattedText;
@property (nonatomic, copy) NSString *tempText;
@property (nonatomic, copy) NSString *formattedTempText;
@property (nonatomic, copy) NSString *nextText;
@property (nonatomic) NSInteger delay;
@property (nonatomic) NSDictionary *fontDictBlack;
@property (nonatomic) NSDictionary *fontDictWhite;
@property (nonatomic) NSDictionary *fontDict;
@property (nonatomic) NSFont *font;
@property (strong, nonatomic) NSStatusItem *enclosingMenu;

- (void) setSettingsController:(SettingsController *) controller;
- (void) setRemaining:(BOOL) rev;
- (BOOL) getRemaining;
- (NSString *) getTime:(NSString *)inp andRemaining:(BOOL) remaining;

@end