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

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

// Part of the window theming hack
@class NSNextStepFrame;
@interface NBBWindow()
- (void)drawRect:(NSRect)rect;
- (NSRect)bounds;
- (NSWindow*)window;
@end

@implementation NBBWindow

+ (void)load
{
	Class frameClass = [NSNextStepFrame class];
	Method m0 = class_getInstanceMethod(self, @selector(drawFrame:));
	class_addMethod(frameClass, @selector(drawFrame:), method_getImplementation(m0), method_getTypeEncoding(m0));

	Method m1 = class_getInstanceMethod(frameClass, @selector(drawRect:));
	Method m2 = class_getInstanceMethod(frameClass, @selector(drawFrame:));

	method_exchangeImplementations(m1, m2);
}

- (void)drawFrame:(NSRect)rect
{
	NBBTheme* theme = [[NBBThemeEngine sharedThemeEngine] theme];
	[self drawFrame:rect];

	NSRect frameRect = [self bounds];

    NSBezierPath* border = [NSBezierPath bezierPathWithRect:frameRect];
    [border setLineWidth:[theme borderWidthForObject:self.window] * self.window.screen.backingScaleFactor];
    [[theme borderColorForObject:self.window] set];
    [border stroke];
}

- (void)finalizeInit
{
	[super finalizeInit];
	[[NBBThemeEngine sharedThemeEngine] themeObject:self];
}

- (BOOL)applyTheme:(NBBTheme*) theme
{
	self.backgroundColor = theme.windowBackgroundColor;

	return YES;
}

- (void)orderBack:(id)sender
{
	[self orderOut:sender];
}

- (void)orderOut:(id)sender
{
	// actual order out takes place on animation completion.
	[[self animator] setValue:nil forKey:NSAnimationTriggerOrderOut];
}

- (void)orderWindow:(NSWindowOrderingMode)orderingMode relativeTo:(NSInteger)otherWindowNumber
{
	// we set the animations here to keep them updated if they change
	// also default animations are based on the applications window size
	CAAnimation* inAnim = [[self theme] windowInAnimation];
	inAnim.delegate = self;
	CAAnimation* outAnim = [[self theme] windowOutAnimation];
	outAnim.delegate = self;

	[self setAnimations:@{ NSAnimationTriggerOrderIn  : inAnim,
						   NSAnimationTriggerOrderOut : outAnim,
						}];

	[super orderWindow:orderingMode relativeTo:otherWindowNumber];
	if (orderingMode == NSWindowAbove) {
		[[self animator] setValue:nil forKey:NSAnimationTriggerOrderIn];
	}
}

#pragma mark Animation Delegation
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	if (flag
		&& [[theAnimation valueForKey:@"animationType"] isEqualToString:NSAnimationTriggerOrderOut]) {
		[super orderOut:nil];
	}
}

@end
