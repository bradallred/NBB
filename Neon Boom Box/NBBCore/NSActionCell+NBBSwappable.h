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
#import "NBBSwappableControl.h"

/*
 This category will implement most of the NBBSwappableControl protocol
 since the same code will apply to ALL	action cells
 
 We will use iOS style icon "jiggling".
 Touch and hold a swappable control to cause it and all COMPATIBLE swappable controls to jiggle
 While jiggling you may drag a control onto another jiggling control to initiate a swap
 */

@interface NSActionCell (NBBSwappable) <NBBSwappableControl, NSDraggingSource, NSDraggingDestination>
@property (nonatomic, retain) id <NBBSwappableControlDelegate> swapDelegate;

- (void)setSwappingEnabled:(BOOL) enable;
- (BOOL)swappingEnabled;
- (void)swapStateChanged:(NSNotification*) notification;
@end
