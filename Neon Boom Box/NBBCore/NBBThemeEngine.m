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

#import "NBBThemeEngine.h"

@implementation NBBThemeEngine

// singleton pattern
#pragma mark - Singleton

+ (NBBThemeEngine*)sharedThemeEngine
{
	static NBBThemeEngine* sharedThemeEngine = nil;
    if (sharedThemeEngine == nil) {
        sharedThemeEngine = [[super allocWithZone:NULL] init];
    }
    return sharedThemeEngine;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedThemeEngine] retain];
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
    self = [super init];
    if (self) {
		NSLog(@"initializing NBB theme engine.");
		_themedObjects = [[NSMutableSet alloc] init];
		_theme = nil;
    }
    return self;
}

- (void)dealloc
{
    [_theme release];
	[_themedObjects release];
    [super dealloc];
}

- (Class <NBBThemable>)classReplacementForThemableClass:(Class <NBBThemable>) cls
{
	Class replacement = cls;
	if ([(Class)cls conformsToProtocol:@protocol(NBBThemable)]) {
		NSLog(@"replacing %@ with %@", cls, replacement);
		// TODO: actually implement this
	}
	return replacement;
}

- (BOOL)themeObject:(id <NBBThemable>) obj
{
	if (_theme && [obj conformsToProtocol:@protocol(NBBThemable)]) {
		if ([obj applyTheme:_theme]) {
			[_themedObjects addObject:obj];
			return YES;
		}
	}
	return NO;
}

- (void)applyTheme:(NBBTheme*) theme
{
	NSLog(@"Applying theme:%@", theme);
	[_theme release];
	_theme = [theme retain];
	for (id <NBBThemable> obj in _themedObjects) {
		[obj applyTheme:_theme];
	}
}

@end
