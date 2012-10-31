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

#import "NBBAppDelegate.h"
#import <Python/Python.h>

@implementation NBBAppDelegate

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"Neon Boom Box started...");
		Py_Initialize(); // we must call Py_Initialize before attempting to load themes!
		_themeEngine = [NBBThemeEngine sharedThemeEngine];
		
		// get the current theme from user defaults
		// if the theme is not set or no longer exists
		// we will apply the first theme found
		NSString* themeName = [[NSUserDefaults standardUserDefaults] stringForKey:@"NBBActiveTheme"];
		NSString* themePath = [[NSBundle mainBundle] pathForResource:themeName ofType:@"nbbtheme" inDirectory:@"Themes"];
		if (!themePath) {
			NSLog(@"theme not found. loading first theme I find.");
			// just grab the first nbbtheme bundle
			NSString* themeDir = [NSString stringWithFormat:@"%@/Contents/Themes", [[NSBundle mainBundle] bundlePath]];
			NSArray* themes = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:themeDir error:nil];
			NSLog(@"available themes: %@ located in %@", themes, themeDir);
			themes = [themes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.nbbtheme'"]];
			themePath = [NSString stringWithFormat:@"%@/%@", themeDir, [themes objectAtIndex:0]];
		}
		NSLog(@"Loading theme: %@", themePath);
		NSBundle* themeBundle = [NSBundle bundleWithPath:themePath];
		if (!themeBundle) {
			@throw([NSException exceptionWithName:@"NoThemeLoadedException"
										   reason:@"No loadable themes found"
										 userInfo:nil]);
		}
		
		Class themeClass = [themeBundle principalClass];
		if (!themeClass || ![themeClass isSubclassOfClass:[NBBTheme class]]) {
			@throw([NSException exceptionWithName:@"NoThemeLoadedException"
										   reason:[NSString stringWithFormat:@"Bundle principle class '%@' is not a subclass of NBBTheme.", themeClass]
										 userInfo:nil]);
		}
		
		NBBTheme* theme = [[themeClass alloc] init];
		[_themeEngine applyTheme:theme];
		[theme release];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

@end
