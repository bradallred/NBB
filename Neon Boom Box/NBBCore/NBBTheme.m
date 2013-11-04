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

#import <QuartzCore/QuartzCore.h>

#import "NBBTheme.h"
#import "NBBThemeEngine.h"

@implementation NBBTheme

+ (NBBTheme*)activeTheme
{
	return [NBBThemeEngine sharedThemeEngine].theme;
}

- (void)dealloc
{
    self.identifier = nil;
	self.prefrences = nil;
    [super dealloc];
}

- (NSFont*)smallFont
{
	return [NSFont controlContentFontOfSize:14.0];
}

- (NSFont*)normalFont
{
	return [NSFont controlContentFontOfSize:24.0];
}

- (NSFont*)largeFont
{
	return [NSFont controlContentFontOfSize:32.0];
}

- (NSColor*)textColor
{
	return [NSColor textColor];
}

- (NSColor*)cellForegroundColor
{
	return [NSColor controlTextColor];
}

- (NSColor*)labelForegroundColor
{
	return self.textColor;
}

- (NSColor*)cellBackgroundColor
{
	return [NSColor controlBackgroundColor];
}
- (NSColor*)labelBackgroundColor
{
	return [NSColor clearColor];
}

- (NSColor*)highlightColor
{
	return [NSColor highlightColor];
}

- (NSColor*)windowBackgroundColor
{
	return [NSColor windowBackgroundColor];
}

- (CAAnimation*)windowInAnimation
{
	// assumes all windows are the same size.
	NSWindow* keyWin = [NSApp keyWindow];

	CABasicAnimation* alphaAnim = [CABasicAnimation animationWithKeyPath:@"alphaValue"];
	alphaAnim.toValue = [NSNumber numberWithDouble:1.0];

	CABasicAnimation* anim = nil;
	if (keyWin) {
		anim = [CABasicAnimation animationWithKeyPath:@"frame"];
		// FIXME: hardcoded size
		NSRect rect = NSMakeRect(0.0, 0.0, 800.0, 480.0);
		anim.toValue = [NSValue valueWithRect:rect];

		NSPoint fromPoint = NSMakePoint(0.5, rect.size.height);
		rect.origin = fromPoint;
		rect.size.height = 2.0;
		anim.fromValue = [NSValue valueWithRect:rect];
	} else {
		anim = [CABasicAnimation animationWithKeyPath:@"frameOrigin"];
		anim.toValue = [NSValue valueWithPoint:NSZeroPoint];
	}

	CAAnimationGroup *group = [CAAnimationGroup animation];
	group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	group.duration = 0.5;
	group.repeatCount = 1.0;
	[group setValue:NSAnimationTriggerOrderIn forKey:@"animationType"];
	group.animations = @[alphaAnim, anim];

	return group;
}

- (CAAnimation*)windowOutAnimation
{
	// FIXME: hardcoded size
	NSRect rect = NSMakeRect(0.0, 480.0, 800.0, 2.0);

	CABasicAnimation* alphaAnim = [CABasicAnimation animationWithKeyPath:@"alphaValue"];
	alphaAnim.toValue = [NSNumber numberWithDouble:0.5];

	CABasicAnimation* collapseAnim = [CABasicAnimation animationWithKeyPath:@"frame"];
	//rect.origin.y = NSHeight(rect);
	collapseAnim.toValue = [NSValue valueWithRect:rect];

	CAAnimationGroup *group = [CAAnimationGroup animation];
	group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	group.duration = 0.5;
	group.repeatCount = 1.0;
	[group setValue:NSAnimationTriggerOrderOut forKey:@"animationType"];
	group.animations = @[alphaAnim, collapseAnim];

	return group;
}

// combination for font, color and alignment
- (NSDictionary*)cellTextAttributes
{
	NSMutableParagraphStyle* ps = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	ps.alignment = NSCenterTextAlignment;
	return @{ NSForegroundColorAttributeName : [self cellForegroundColor],
			  NSFontAttributeName : [self normalFont],
			  NSParagraphStyleAttributeName : ps};
}

- (NSDictionary*)labelTextAttributes
{
	NSMutableParagraphStyle* ps = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	ps.alignment = NSCenterTextAlignment;
	return @{ NSForegroundColorAttributeName : [self labelForegroundColor],
			  NSFontAttributeName : [self normalFont],
			  NSParagraphStyleAttributeName : ps};
}

- (NSColor*)foregroundColorForObject:(id <NSUserInterfaceItemIdentification, NSObject>) object
{
	if ([object isKindOfClass:[NSTextField class]]) {
		return self.labelForegroundColor;
	}
	if ([object isKindOfClass:[NSControl class]]) {
		return self.cellForegroundColor;
	}
	return self.textColor;
}

- (NSColor*)backgroundColorForObject:(id <NSUserInterfaceItemIdentification, NSObject>) object
{
	if ([object isKindOfClass:[NSTextField class]]) {
		return self.labelBackgroundColor;
	}
	if ([object isKindOfClass:[NSControl class]]) {
		return self.cellBackgroundColor;
	}
	return [NSColor clearColor];
}

- (NSColor*)borderColorForObject:(id <NSUserInterfaceItemIdentification, NSObject>) object
{
	if ([object isKindOfClass:[NSWindow class]]) {
		return [NSColor windowFrameColor];
	}
	return [NSColor gridColor];
}

- (CGFloat)borderWidthForObject:(id <NSUserInterfaceItemIdentification, NSObject>) object
{
	return 2.0;
}

- (NSRect)frameForObject:(NSView*) view
{
	return view.frame;
}

// default theme preferences should supply the frames for controls
// if the theme wishes controls to have a layout diffrent from NIB
// you can also override any application default preference
- (NSDictionary*)defaultThemePrefrences
{
	return @{};
}

@end
