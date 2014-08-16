//ScrollingTextView.m
//Adapted from http://stackoverflow.com/a/3233802/3438793

#import "ScrollingTextView.h"
#import "AppDelegate.h"
#import "SettingsController.h"

@implementation ScrollingTextView

@synthesize speed;
@synthesize text;
@synthesize formattedText;
@synthesize tempText;
@synthesize formattedTempText;
@synthesize nextText;
@synthesize delay;
@synthesize fontDictBlack;
@synthesize fontDictWhite;
@synthesize fontDict;
@synthesize font;
@synthesize enclosingMenu;

- (id) init
{
    self = [super init];
    if (self) {
        self.iTunes = [(AppDelegate *)[[NSApplication sharedApplication] delegate] iTunes];
    }
    return self;
}

- (void) setText:(NSString *)newText {
    font = [NSFont fontWithName:@"Lucida Grande" size:15.0];
    fontDictBlack = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [NSNumber numberWithFloat:5.0], NSBaselineOffsetAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, nil];
    fontDictWhite = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [NSNumber numberWithFloat:5.0], NSBaselineOffsetAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, nil];
    if (!fontDict) {
        fontDict = fontDictBlack;
    }
    
    BOOL first = (text == nil);
    if (first) {
        text = [newText copy];
        point = NSZeroPoint;
    } else {
        nextText = [newText copy];
    }
    
    nextWidth = [newText sizeWithAttributes:fontDict].width;
    
    if (first) {
        stringWidth = nextWidth;
    }
    
    if (nextWidth <= 300) {
        if (first) {
            [self setFrameSize:NSSizeFromString([NSString stringWithFormat:@"{%f, 22}", nextWidth])];
        }
        nextSize = nextWidth;
    } else {
        if (first) {
            [self setFrameSize:NSSizeFromString(@"{300, 22}")];
        }
        nextSize = 300;
    }
    
    if (text != nil && speed > 0 && (text != nil || nextText != nil)) {
        [scroller invalidate];
        scroller = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(timerInc:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:scroller forMode:NSRunLoopCommonModes];
    }
    
    if (first) {
        draw = false;
        delay = 200;
    }
}

- (void) setSpeed:(NSTimeInterval)newSpeed {
    if (newSpeed != speed) {
        speed = newSpeed;
        
        [scroller invalidate];
        scroller = nil;
        if (speed > 0 && text != nil) {
            scroller = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(timerInc:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:scroller forMode:NSRunLoopCommonModes];
        }
    }
}

- (void) setRemaining:(BOOL) rev {
    remaining = rev;
}
- (BOOL) getRemaining {
    return remaining;
}

- (void) mouseDown:(NSEvent *)theEvent{
    [super mouseDown:theEvent];
    [(AppDelegate *)[[NSApplication sharedApplication] delegate] onClick];
}
- (void) rightMouseDown:(NSEvent *)theEvent{
    [super rightMouseDown:theEvent];
    [(AppDelegate *)[[NSApplication sharedApplication] delegate] onClick];
}

- (void) menuWillOpen:(NSMenu *)menu {
    isMenuShowing = YES;
	[self setNeedsDisplay:YES];
}

- (void) menuDidClose:(NSMenu *)menu {
	isMenuShowing = NO;
	[self setNeedsDisplay:YES];
}

- (void) setSettingsController:(SettingsController *) controller {
    settings = controller;
}

- (void) timerInc:(NSTimer *)timer {
    CGFloat size = self.frame.size.width;
    
    if (nextSize > 299) {
        nextSize = 300;
    }
    
    if (size+2 < nextSize) {
        [self setFrameSize:NSSizeFromString([NSString stringWithFormat:@"{%f, 22}", size + 2])];
        isBigger = (nextSize == 300);
    } else if (size-2 > nextSize) {
        if (shouldShrink) {
            [self setFrameSize:NSSizeFromString([NSString stringWithFormat:@"{%f, 22}", size - 2])];
            if (tempText != nil) {
                text = tempText;
                tempText = nil;
            }
            isBigger = false;
        }
    }
    
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    if (tempText == nil) {
        formattedText = [self getTime:text andPos:[delegate timeLeft] andRemaining:remaining];
    } else {
        formattedTempText = [self getTime:tempText andPos:[delegate timeLeft] andRemaining:remaining];
    }
    
    if ([delegate fileWrite]) {
        if ([delegate fileWriteTime]) {
            if (tempText == nil) {
                [self writeToTextFile: [self getTime:text andPos:[delegate timeLeft] andRemaining:remaining]];
            } else {
                [self writeToTextFile: [self getTime:tempText andPos:[delegate timeLeft] andRemaining:remaining]];
            }
        } else {
            if (tempText == nil) {
                [self writeToTextFile: text];
            } else {
                [self writeToTextFile: tempText];
            }
        }
    }
    
    if (settings) {
        [settings controlTextDidChange:nil];
    }
    
    [self setNeedsDisplay:YES];
}

- (void) writeToTextFile:(NSString *)str
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    
    NSString *fileName = [NSString stringWithFormat:@"%@/WAILT.txt", directory];
    [str writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *) getTime:(NSString *)inp andPos:(BOOL) onLeft andRemaining:(BOOL) remain {
    if (self.iTunes == nil) {
        self.iTunes = [(AppDelegate *)[[NSApplication sharedApplication] delegate] iTunes];
    }
    NSMutableString *str = [NSMutableString string];
    [str appendString:inp];
    
    double position = [self.iTunes playerPosition];
    double duration = [[self.iTunes currentTrack] duration];
    if (remain && ([self.iTunes currentStreamTitle] == nil || [[self.iTunes currentStreamTitle] isEqualToString:@""])) {
        position = duration - position;
    }
    
    int hrs = 0;
    int mins = 0;
    int secs = 0;
    int total = 0;
    
    for (int i = 0; i < position; i++) {
        total++;
        secs++;
        if (secs % (int)60 == 0) {
            secs = 0;
            mins++;
            if (mins % (int)60 == 0) {
                mins = 0;
                hrs++;
            }
        }
    }
    double left = position-total;
    if (left >= 0.5) {
        secs++;
        if (secs % (int)60 == 0) {
            secs = 0;
            mins++;
            if (mins % (int)60 == 0) {
                mins = 0;
                hrs++;
            }
        }
    }
    
    NSMutableString *time = [NSMutableString string];
    if (remain && ([self.iTunes currentStreamTitle] == nil || [[self.iTunes currentStreamTitle] isEqualToString:@""])) {
        [time appendString:@"-"];
    }
    if (hrs > 0) {
        [time appendFormat:@"%i:", hrs];
    }
    if (hrs > 0 || mins > 0) {
        [time appendFormat:(hrs > 0 && mins < 10 ? @"0%i:" : @"%i:"), mins];
    } else if (hrs == 0 && hrs == 0) {
        [time appendString:@"0:"];
    }
    [time appendFormat:(secs < 10 ? @"0%i" : @"%i"), secs];
    
    if (onLeft) {
        [str insertString:@"(&time&)#" atIndex:[str rangeOfString:@"]"].location+2];
    } else {
        [str insertString:@"#(&time&)" atIndex:[str length]];
    }
    
    [str replaceOccurrencesOfString:@"#" withString:[(AppDelegate *)[[NSApplication sharedApplication] delegate] separator] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"&time&" withString:time options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    return str;
}

- (void) drawRect:(NSRect)dirtyRect
{
    if ([tempText isEqualToString:@"No song playing"] || [nextText isEqualToString:@"No song playing"]) {
        tempText = nil;
        nextText = nil;
        text = @"No song playing";
    }
    
    if (isMenuShowing) {
        [[NSColor selectedMenuItemColor] set];
        NSRectFill(dirtyRect);
        fontDict = fontDictWhite;
    } else {
        fontDict = fontDictBlack;
    }
    
    if (isBigger) {
        if (draw) {
            if (!shouldShrink) {
                point.x = point.x - 1.0f;
            }
            
            CGFloat pointX = dirtyRect.size.width + (-1*(dirtyRect.size.width - stringWidth)) + 30;
            
            if (point.x < -1*pointX) {
                point.x += pointX;
                if (tempText != nil) {
                    text = tempText;
                    tempText = nil;
                    stringWidth = nextWidth;
                }
                if (tempText == nil) {
                    draw = false;
                    delay = 200;
                }
            }
            
            [formattedText drawAtPoint:point withAttributes:fontDict];
            
            if (point.x + pointX < dirtyRect.size.width) {
                NSPoint otherPoint = point;
                otherPoint.x += pointX;
                if (tempText != nil) {
                    if (nextSize < dirtyRect.size.width && otherPoint.x >= -1 && otherPoint.x <= 1) {
                        shouldShrink = true;
                    }
                    [formattedTempText drawAtPoint:otherPoint withAttributes:fontDict];
                } else {
                    [formattedText drawAtPoint:otherPoint withAttributes:fontDict];
                    if (nextText != nil) {
                        if (speed < 0.015) {
                            [self setSpeed:speed+0.001];
                        } else if (speed > 0.015) {
                            [self setSpeed:speed-0.001];
                        }
                    }
                }
            } else if (nextText != nil) {
                tempText = nextText;
                nextText = nil;
            } else if (tempText != nil) {
                if (speed < 0.015) {
                    [self setSpeed:speed+0.001];
                } else if (speed > 0.015) {
                    [self setSpeed:speed-0.001];
                }
            }
        } else {
            if (nextText == nil && speed != 0.03) {
                [self setSpeed:0.03];
            }
            if (nextText != nil) {
                tempText = nextText;
                nextText = nil;
                [self setSpeed:0.015];
            }
            if (tempText != nil) {
                draw = true;
                delay = 0;
            }
            
            point.x = 0;
            [formattedText drawAtPoint:point withAttributes:fontDict];
            
            if (delay <= 0) {
                draw = true;
            } else {
                delay -= 1;
            }
        }
    } else {
        point.x = 0;
        
        if (nextText == nil && speed != 0.03) {
            [self setSpeed:0.03];
        }
        if (nextText != nil) {
            tempText = nextText;
            nextText = nil;
            isBigger = true;
            nextSize = 300;
            
            [self setSpeed:0.015];
        }
        
        [formattedText drawAtPoint:point withAttributes:fontDict];
    }
}

@end