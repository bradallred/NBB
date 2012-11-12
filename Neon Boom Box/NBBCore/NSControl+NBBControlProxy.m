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

#import "NSControl+NBBControlProxy.h"
#import "NBBThemeEngine.h"

@implementation NSControl (NBBControlProxy)

+ (id)allocWithZone:(NSZone *)zone
{
	NBBThemeEngine* themeEngine = [NBBThemeEngine sharedThemeEngine];
	self = [themeEngine classReplacementForThemableClass:self];
	return [super allocWithZone:zone];
}

// use this method over awakeFromNib because we need to catch controls that are created dynamically too
- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
	if (newWindow && [self conformsToProtocol:@protocol(NBBThemable)]) {
		[self setWantsLayer:YES]; // nbb uses CA for many control animations
		NBBThemeEngine* themeEngine = [NBBThemeEngine sharedThemeEngine];
		[themeEngine themeObject:(id <NBBThemable>)self];
	}
	[super viewWillMoveToWindow:newWindow]; // shouldnt do anything (default implementation is noop)
}

#pragma mark NSDraggingDestination
// message forwarding doesnt work for NSDraggingDestination methods
// because NSView implements empty methods for the protocol

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
	return [self.cell draggingEntered:sender];
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
	[self.cell draggingExited:sender];
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
	return [self.cell prepareForDragOperation:sender];
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
	return [self.cell performDragOperation:sender];
}

- (void)concludeDragOperation:(id < NSDraggingInfo >)sender
{
	return [self.cell concludeDragOperation:sender];
}

@end
