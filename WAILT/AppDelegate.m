//
//  AppDelegate.m
//  NowPlaying
//
//  Created by thislooksfun on 7/14/14.
//  Copyright (c) 2014 thislooksfun. All rights reserved.
//

#import "AppDelegate.h"
#import "iTunes.h"

@implementation AppDelegate

@synthesize statusBar = _statusBar;
@synthesize scrollingText;
@synthesize currentData;

@synthesize defaultFormat;
@synthesize defaultSeperator;
@synthesize defaultTimeFormat;
@synthesize userFormat;
@synthesize seperator;
@synthesize timeFormat;
@synthesize timeLeft;

- (id) init
{
    self = [super init];
    
    if (!self) return nil;
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(onItunesChange:) name:@"com.apple.iTunes.playerInfo" object:nil];
    
    self.iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    defaultFormat = @"&title&#&name&#&artist&#&album&";
    defaultSeperator = @" — ";
    defaultTimeFormat = @"(hr:min:sec)";
    
    return self;
}

- (void) awakeFromNib
{
    NSDictionary *appDefaults = @{@"format": defaultFormat, @"seperator": defaultSeperator, @"timeFormat": defaultTimeFormat, @"remaining": @false, @"timeOnLeft": @true};
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:appDefaults];
    
    userFormat = [defaults stringForKey:@"format"];
    seperator = [defaults stringForKey:@"seperator"];
    timeFormat = [defaults stringForKey:@"timeFormat"];
    timeLeft = [defaults boolForKey:@"timeOnLeft"];
    [self.scrollingText setRemaining:[defaults boolForKey:@"remaining"]];
    
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
    
    self.statusBar.title = @"WAILT";
    [self.statusBar setView:self.scrollingText];
    [self.statusMenu setDelegate:self.scrollingText];
    [self onItunesChange:nil];
}

- (void) onClick {
    [self.statusBar popUpStatusItemMenu:self.statusMenu];
}

- (void) onItunesChange:(NSNotification *)notification
{
    iTunesEPlS state = [self.iTunes playerState];
    switch (state) {
        case iTunesEPlSStopped: {
            currentData = nil;
            [self.scrollingText setText:@"No song playing"];
            [self.scrollingText setSpeed:0.03];
            [self.statusBar setView:self.scrollingText];
        } break;
        default: {
            [self setSong];
        } break;
    }
}

- (void) setSong {
    NSString *str = [self getSongWithFormat:userFormat andSeperator:seperator andTimeOnLeft:timeLeft];
    
    if (![str isEqualToString:currentData]) {
        [self.scrollingText setText:str];
        [self.scrollingText setSpeed:0.03];
        [self.statusBar setView:self.scrollingText];
        self.currentData = str;
        [self writeToTextFile:str];
    }
}
- (NSString *) getSongWithFormat:(NSString *)form andSeperator:(NSString *)sep andTimeOnLeft:(BOOL) timeOnLeft
{
    iTunesTrack *track = [self.iTunes currentTrack];
    NSMutableString *format = [NSMutableString string];
    [format appendString:form];
    
    NSString *type = [track podcast] ? @"[Podcast]" : ([[track kind] isEqualToString:@"Internet audio stream"] ? @"[Radio]" : @"[Song]");
    NSString *title = [self.iTunes currentStreamTitle] == nil ? @"" : [self.iTunes currentStreamTitle];
    NSString *trName = [track name] == nil ? @"" : [track name];
    NSString *trArtist = [track artist] == nil ? @"" : [track artist];
    NSString *trAlbum = [track album] == nil ? @"" : [track album];
    
    [format replaceOccurrencesOfString:@"&title&"  withString:title    options:NSCaseInsensitiveSearch range:NSMakeRange(0, [format length])];
    [format replaceOccurrencesOfString:@"&name&"   withString:trName   options:NSCaseInsensitiveSearch range:NSMakeRange(0, [format length])];
    [format replaceOccurrencesOfString:@"&artist&" withString:trArtist options:NSCaseInsensitiveSearch range:NSMakeRange(0, [format length])];
    [format replaceOccurrencesOfString:@"&album&"  withString:trAlbum  options:NSCaseInsensitiveSearch range:NSMakeRange(0, [format length])];
    [format replaceOccurrencesOfString:@" # "      withString:@""      options:NSCaseInsensitiveSearch range:NSMakeRange(0, [format length])];
    [format replaceOccurrencesOfString:@" #"       withString:@""      options:NSCaseInsensitiveSearch range:NSMakeRange(0, [format length])];
    [format replaceOccurrencesOfString:@"# "       withString:@""      options:NSCaseInsensitiveSearch range:NSMakeRange(0, [format length])];
    [format replaceOccurrencesOfString:@"  "       withString:@""      options:NSCaseInsensitiveSearch range:NSMakeRange(0, [format length])];
    [format replaceOccurrencesOfString:@"#&"       withString:@""      options:NSCaseInsensitiveSearch range:NSMakeRange(0, [format length])];
    [format replaceOccurrencesOfString:@"&#"       withString:@""      options:NSCaseInsensitiveSearch range:NSMakeRange(0, [format length])];
    while ([format hasSuffix:@"#"]) { [format deleteCharactersInRange:NSMakeRange([format length]-1, 1)]; }
    while ([format hasPrefix:@"#"]) { [format deleteCharactersInRange:NSMakeRange(0, 1)]; }
    if (timeOnLeft) {
        [format insertString:@"(&time&)#" atIndex:0];
    } else {
        [format insertString:@"#(&time&)" atIndex:[format length]];
    }
    [format replaceOccurrencesOfString:@"#" withString:sep options:NSCaseInsensitiveSearch range:NSMakeRange(0, [format length])];
    [format insertString:[type stringByAppendingString:@" "] atIndex:0];
    
    return format;
}

- (void) writeToTextFile:(NSString *)str
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    
    NSString *fileName = [NSString stringWithFormat:@"%@/WAILT.txt", directory];
    [str writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
