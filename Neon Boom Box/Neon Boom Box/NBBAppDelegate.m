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

@implementation NBBAppDelegate
@dynamic dateTime;

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"Neon Boom Box started...");
		// === load user prefrences ===
		// NOTE: we cannot add a search path before the application path if we use standardUserDefaults
		_userPrefrences = [[NSUserDefaults alloc] init];
		NSString* bundleId = [NSBundle mainBundle].bundleIdentifier;
		[_userPrefrences addSuiteNamed:bundleId];

		// === initialize themeing engine ===
		// this must be done BEFORE attempting to initialize ANY theme or loading a theme bundle
		_themeEngine = [NBBThemeEngine sharedThemeEngine];

		// === register for notifications ===
		NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(updateThemePrefs:) name:@"NBBThemeWillChange" object:_themeEngine];

		// === find the theme to use ===

		// get the current theme from user defaults
		// if the theme is not set or no longer exists
		// we will apply the first theme found
		NSString* themeName = [_userPrefrences stringForKey:@"NBBActiveTheme"];
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

		// === add theme preferences to search path ===
		// this is the first search path for prefrences so remove the app domain for now
		[_userPrefrences removeSuiteNamed:bundleId];
		[_userPrefrences addSuiteNamed:themeBundle.bundleIdentifier];
		// !!!: before we initialize anything we need to re-add application domain to the preference search path
		[_userPrefrences addSuiteNamed:bundleId];
		// now theme prefs should override application prefs!
		// === register defaults ===
		// this MUST come last in search path
		// TODO: setup a default plist and load it here
		[_userPrefrences registerDefaults:@{}]; // will create NSRegistrationDomain for us and add it to path

		// === initialize the selected theme ===
		NBBTheme* theme = [[themeClass alloc] init];
		theme.identifier = themeBundle.bundleIdentifier;
		theme.prefrences = [NSMutableDictionary dictionaryWithDictionary:[_userPrefrences persistentDomainForName:themeBundle.bundleIdentifier]];
		[_themeEngine applyTheme:theme];
		[theme release];

		// === start a time clock ===
		NSTimer* timer = [NSTimer timerWithTimeInterval:1.0
												 target:self
											   selector:@selector(updateDateTime:)
											   userInfo:nil
												repeats:YES];

		// we need to add the timer for all common modes so the clock will update during event tracking
		[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)dealloc
{
	[_userPrefrences release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[_themeEngine updateLayout];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[self updateThemePrefs:nil];
	[_userPrefrences synchronize];
}

- (NSDate*)dateTime
{
	return [NSDate date];
}

- (void)updateDateTime:(NSTimer*)timer
{
	// manual KVO notifications
	[self willChangeValueForKey:@"dateTime"];
	[self didChangeValueForKey:@"dateTime"];
}

- (void)updateThemePrefs:(NSNotification*) notification
{
	// don't bother using the notification since we call this with nil on dealloc
	NBBTheme* theTheme = _themeEngine.theme;
	NSLog(@"saving settings for:%@\n%@", theTheme.identifier, theTheme.prefrences);
	[_userPrefrences setPersistentDomain:theTheme.prefrences forName:theTheme.identifier];
}

@end
