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

#import "NBBWindow.h"
#import "NBBThemeEngine.h"

@implementation NBBWindow

- (void)finalizeInit
{
	[self setReleasedWhenClosed:NO];
	[self setMovableByWindowBackground:NO];
	[self setHasShadow:NO];
	self.collectionBehavior = NSWindowCollectionBehaviorFullScreenPrimary;

	[[NBBThemeEngine sharedThemeEngine] themeObject:self];
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{	
	self = [super initWithContentRect:contentRect
							styleMask:NSBorderlessWindowMask
							  backing:NSBackingStoreBuffered
								defer:deferCreation];
	
    if (self) {
		[self finalizeInit];
    }
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation screen:(NSScreen *)screen
{
	return [self initWithContentRect:contentRect styleMask:windowStyle backing:bufferingType defer:deferCreation];
}

- (BOOL)applyTheme:(NBBTheme*) theme
{
	self.backgroundColor = theme.windowBackgroundColor;

	NSView* cv = self.contentView;
	NSView* fv = cv.superview;
	fv.wantsLayer = YES;
	cv.wantsLayer = NO; // fucks with arrangeable controls
	fv.layer.borderColor = [[theme borderColorForObject:self] CGColor];
	fv.layer.borderWidth = [theme borderWidthForObject:self];

	return YES;
}

- (void)awakeFromNib
{
	[self finalizeInit];
}

- (BOOL) canBecomeKeyWindow
{
	return YES;
}

@end
