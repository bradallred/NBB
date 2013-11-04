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

@interface NBBWindowFrameProxy : NSProxy
@property(readwrite) NSRect frame;
@property(readonly) NSWindow* window;

- (void)drawRect:(NSRect)rect;
@end

@implementation NBBWindowFrameProxy
@dynamic frame, window;

+ (void)load
{
	Class frameClass = NSClassFromString(@"NSNextStepFrame");
	SEL drawSEL = @selector(drawRect:);
	Method m1 = class_getInstanceMethod(self, drawSEL);
	Method m2 = class_getInstanceMethod(frameClass, drawSEL);

	IMP imp1 = method_getImplementation(m1);
	method_setImplementation(m2, imp1);
}

- (void)drawRect:(NSRect)rect
{
	if ([self.window conformsToProtocol:@protocol(NBBThemable)]) {
		NBBTheme* theme = [[NBBThemeEngine sharedThemeEngine] theme];
		NSRect frameRect = [self frame];

		NSBezierPath* border = [NSBezierPath bezierPathWithRect:frameRect];
		[border setLineWidth:[theme borderWidthForObject:self.window] * self.window.screen.backingScaleFactor];
		[[theme borderColorForObject:self.window] set];
		[border stroke];
	}
}
@end

@implementation NBBWindow

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
	[[self animator] setValue:@"" forKey:NSAnimationTriggerOrderOut];
}

- (void)orderWindow:(NSWindowOrderingMode)orderingMode relativeTo:(NSInteger)otherWindowNumber
{
	// we set the animations here to keep them updated if they change
	// also default animations are based on the applications window size
	CAAnimation* inAnim = [[NBBTheme activeTheme] windowInAnimation];
	inAnim.delegate = self;
	CAAnimation* outAnim = [[NBBTheme activeTheme] windowOutAnimation];
	outAnim.delegate = self;

	[self setAnimations:@{ NSAnimationTriggerOrderIn  : inAnim,
						   NSAnimationTriggerOrderOut : outAnim,
						}];

	[super orderWindow:orderingMode relativeTo:otherWindowNumber];
	if (orderingMode == NSWindowAbove) {
		[[self animator] setValue:@"" forKey:NSAnimationTriggerOrderIn];
	}
}

+ (id)defaultAnimationForKey:(NSString *)key
{
	if ([key isEqualToString:NSAnimationTriggerOrderIn])
    {
        return [[NBBThemeEngine sharedThemeEngine].theme windowInAnimation];
    }
	if ([key isEqualToString:NSAnimationTriggerOrderOut])
    {
		return [[NBBThemeEngine sharedThemeEngine].theme windowOutAnimation];
    }
	return [super defaultAnimationForKey:key];
}

#pragma mark Animation Delegation
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	if (flag) {
		if ([[theAnimation valueForKey:@"animationType"] isEqualToString:NSAnimationTriggerOrderOut]) {
			[super orderOut:nil];
		} else if ([[theAnimation valueForKey:@"animationType"] isEqualToString:NSAnimationTriggerOrderIn]) {
			// ensure the window is always in place after the animation
			// FIXME: this seems like a hack. why is the animation sometimes ending at the wrong point?
			[self setFrameOrigin:NSZeroPoint];
		}
	}
}

@end
