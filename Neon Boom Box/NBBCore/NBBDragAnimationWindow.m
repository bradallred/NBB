/* Neon Boom Box - In-car entertainment front-end
 * Copyright (C) 2012 Brad Allred
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

#import "NBBDragAnimationWindow.h"

// TODO: animation window ought to have a view property designating the view it is representing
// then we can move most of the drag animation code here where it belongs

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
