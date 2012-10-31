//
//  NBBDragAnimationWindow.m
//  Neon Boom Box
//
//  Created by Brad on 10/30/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

#import "NBBDragAnimationWindow.h"

@implementation NBBDragAnimationWindow

// singleton pattern
#pragma mark - Singleton

+ (NBBDragAnimationWindow*)sharedAnimationWindow
{
	static NBBDragAnimationWindow* sharedAnimationWindow = nil;
    if (sharedAnimationWindow == nil) {
        sharedAnimationWindow = [[super allocWithZone:NULL] init];
    }
    return sharedAnimationWindow;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedAnimationWindow] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

// end singleton pattern

- (id)init
{
    self = [super initWithContentRect:NSZeroRect
							styleMask:NSBorderlessWindowMask
							  backing:NSBackingStoreBuffered
								defer:NO];

    if (self) {
		NSLog(@"initializing NBB drag animation window.");

		[self setReleasedWhenClosed:NO];
		[self setMovableByWindowBackground:NO];
		[self setBackgroundColor:[NSColor clearColor]];
		[self setLevel:(NSFloatingWindowLevel + 3000)];
		[self setOpaque:NO];
		[self setHasShadow:NO];
		[[self contentView] setWantsLayer:YES];
    }
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation screen:(NSScreen *)screen
{
	return [self init];
}

@end
