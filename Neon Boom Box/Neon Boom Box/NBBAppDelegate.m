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
		[_userPrefrences addSuiteNamed:[NSBundle mainBundle].bundleIdentifier];

		// === initialize themeing engine ===
		// this must be done BEFORE attempting to initialize ANY theme or loading a theme bundle
		_themeEngine = [NBBThemeEngine sharedThemeEngine];

		// === register for notifications ===
		NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(updateThemePrefs:) name:@"NBBThemeWillChange" object:_themeEngine];
		[nc addObserver:self selector:@selector(themeChanged:) name:@"NBBThemeDidChange" object:_themeEngine];

		// === find all available themes ===
		NSString* themeDir = [NSString stringWithFormat:@"%@/Contents/Themes", [[NSBundle mainBundle] bundlePath]];
		_availableThemes = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:themeDir error:nil];
		_availableThemes = [_availableThemes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.nbbtheme'"]];
		[_availableThemes retain];

		// === find the theme to use ===

		// get the current theme from user defaults
		// if the theme is not set or no longer exists
		// we will apply the first theme found
		NSString* themeIdentifier = [_userPrefrences stringForKey:@"NBBActiveTheme"];

		NBBTheme* theme = [self themeWithIdentifier:themeIdentifier];
		if (!theme && _availableThemes.count) {
			NSLog(@"assigned theme not found. loading first theme I find.");
			// just grab the first nbbtheme bundle
			theme = [self themeWithName:[_availableThemes objectAtIndex:0]];
		}
		// this will throw an exception if theme is nil
		[_themeEngine applyTheme:theme];

		// === register defaults ===
		// this MUST come last in search path
		NSDictionary* defaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
															pathForResource:@"defaults"
																	 ofType:@"plist"]];
		[_userPrefrences registerDefaults:defaults]; // will create NSRegistrationDomain for us and add it to path

		// === start a time clock ===
		NSTimer* timer = [NSTimer timerWithTimeInterval:1.0
												 target:self
											   selector:@selector(updateDateTime:)
											   userInfo:nil
												repeats:YES];

		// we need to add the timer for all common modes so the clock will update during event tracking
		[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

		// === the very last thing is to load the modules ===
		NSString* moduleDir = [NSBundle mainBundle].builtInPlugInsPath;
		_availableModules = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:moduleDir error:nil];
		_availableModules = [_availableModules filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.nbbmodule'"]];
		//[NSThread detachNewThreadSelector:@selector(loadModules) toTarget:self withObject:nil];
		NSOperationQueue* loaderQueue = [[NSOperationQueue alloc] init];
		[loaderQueue setMaxConcurrentOperationCount:[_availableModules count]];
		for (NSString* module in _availableModules) {
			NSString* path = [NSString stringWithFormat:@"%@/%@", moduleDir, module];
			NSBundle* moduleBundle = [NSBundle bundleWithPath:path];
			id moduleClass = moduleBundle.principalClass;
			if ([moduleClass isSubclassOfClass:[NBBModule class]]) {
				[loaderQueue addOperationWithBlock:^{
					// load the module
					NSString* nibName = [[moduleBundle infoDictionary] objectForKey:@"NSMainNibFile"];
					if (nibName) {
						NBBModule* module = [[moduleClass alloc] initWithWindowNibName:nibName];
					} else {
						@throw([NSException exceptionWithName:@"NBBNotValidModuleException"
													   reason:@"Modules must have an NSMainNibFile defined"
													 userInfo:nil]);
					}
				}];
			} else {
				@throw([NSException exceptionWithName:@"NBBNotValidModuleException"
											   reason:[NSString stringWithFormat:@"Bundle principle class '%@' is not a subclass of NBBModule.", moduleClass]
											 userInfo:nil]);
			}
		}
    }
    return self;
}

- (void)dealloc
{
	[_availableThemes release];
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

	if (notification) {
		// the theme is changing so remove it from the search path
		[_userPrefrences synchronize]; // save before removing the suite
		[_userPrefrences removeSuiteNamed:theTheme.identifier];
	}
}

- (void)themeChanged:(NSNotification*) notification
{
	NBBThemeEngine* engine = notification.object;
	// === add theme preferences to search path ===
	// this is the first search path for prefrences so remove the app domain then re-add
	NSString* identifier = [NSBundle mainBundle].bundleIdentifier;
	[_userPrefrences removeSuiteNamed:identifier];
	[_userPrefrences addSuiteNamed:engine.theme.identifier];
	[_userPrefrences addSuiteNamed:identifier];
	// now theme prefs should override application prefs!

	// set the new theme to the preference default
	[_userPrefrences setObject:engine.theme.identifier forKey:@"NBBActiveTheme"];
}

- (NBBTheme*)themeFromBundle:(NSBundle*) themeBundle
{
	if (!themeBundle) {
		return nil;
	}

	Class themeClass = [themeBundle principalClass];
	if (!themeClass || ![themeClass isSubclassOfClass:[NBBTheme class]]) {
		@throw([NSException exceptionWithName:@"NBBNotValidThemeException"
									   reason:[NSString stringWithFormat:@"Bundle principle class '%@' is not a subclass of NBBTheme.", themeClass]
									 userInfo:nil]);
	}

	NBBTheme* theTheme = [[themeClass alloc] init];
	// === initialize the theme ===
	theTheme.identifier = themeBundle.bundleIdentifier;
	theTheme.prefrences = [NSMutableDictionary dictionaryWithDictionary:[_userPrefrences persistentDomainForName:themeBundle.bundleIdentifier]];

	return [theTheme autorelease];
}

- (NBBTheme*)themeWithIdentifier:(NSString*) identifier
{
	return [self themeWithName:[identifier pathExtension]];
}

- (NBBTheme*)themeWithName:(NSString*) themeName
{
	// we should accept a name with or without the extension
	NSString* themePath = [[NSBundle mainBundle] pathForResource:themeName ofType:@"nbbtheme" inDirectory:@"../Themes"];
	if (!themePath) {
		themePath = [[NSBundle mainBundle] pathForResource:themeName ofType:nil inDirectory:@"../Themes"];
	}
	if (!themePath) {
		return nil;
	}
	NSBundle* themeBundle = [NSBundle bundleWithPath:themePath];
	return [self themeFromBundle:themeBundle];
}

@end
