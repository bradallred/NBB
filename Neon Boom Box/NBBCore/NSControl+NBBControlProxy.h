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

#import <Cocoa/Cocoa.h>

@class NBBTheme;

/*
This category exists to intercept alloc calls for controls adopting the NBBThemable protocol.
The goal is to allocate and return overriding theme specific subclasses instead
*/

@interface NSControl (NBBControlProxy)
+ (id)allocWithZone:(NSZone *)zone;
- (void)viewWillMoveToWindow:(NSWindow *)newWindow;

- (NSDraggingSession*)beginDraggingSessionWithDraggingCell:(NSCell <NSDraggingSource> *)cell event:(NSEvent*) theEvent;
- (NSImage*)imageForCell:(NSCell*)cell;
- (NSImage*)imageForCell:(NSCell*)cell highlighted:(BOOL) highlight;
- (NSRect)frameForCell:(NSCell*)cell;
@end
