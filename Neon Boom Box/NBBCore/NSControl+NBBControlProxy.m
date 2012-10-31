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

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
	if ([self conformsToProtocol:@protocol(NBBThemable)]) {
		NBBThemeEngine* themeEngine = [NBBThemeEngine sharedThemeEngine];
		[themeEngine themeObject:(id <NBBThemable>)self];
	}
	[super viewWillMoveToWindow:newWindow]; // shouldnt do anything (default implementation is noop)
}

@end
