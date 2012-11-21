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
		_loaderQueue = [[NSOperationQueue alloc] init];

		[nc addObserver:self selector:@selector(updateThemePrefs:) name:@"NBBThemeWillChange" object:_themeEngine];
		[nc addObserver:self selector:@selector(themeChanged:) name:@"NBBThemeDidChange" object:_themeEngine];
		[nc addObserverForName:@"NBBModuleLoaded" object:nil
			queue:_loaderQueue usingBlock:^(NSNotification *note) {
				if (self.launchpad) {
					[self.launchpad addCellForModule:note.object];
				} else {
					@throw([NSException exceptionWithName:@"NBBIncompleteInterfaceException"
												   reason:@"No module launchpad in place."
												 userInfo:nil]);
				}
			}
		 ];

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
			theme = [self themeWithName:_availableThemes[0]];
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
    }
	// === REMAINDER OF SETUP HAPPENS IN applicationDidFinishLaunching ===
    return self;
}

- (void)dealloc
{
	// this isnt needed unless somehow the application gets a new delegate
	// would have to be due to 3rd party mod
	[_loaderQueue release];
	[_availableThemes release];
	[_userPrefrences release];
	@synchronized(_loadedModules) {
		[_loadedModules release];
	}
	self.homeWindow = nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// === THEME SETUP MUST BE DONE PRIOR === see init
	// open the home screen
	NSArray* objects = nil;
	if ([[NSBundle mainBundle] loadNibNamed:@"Home" owner:self topLevelObjects:&objects]) {
		for (id obj in objects) {
			if ([obj isKindOfClass:[NBBWindow class]]) {
				self.homeWindow = obj;
				[obj makeKeyAndOrderFront:self];
				break;
			}
		}
		[_themeEngine updateLayout];
		// load the modules after the interface

		// === the very last thing is to load the modules ===
		NSString* moduleDir = [NSBundle mainBundle].builtInPlugInsPath;
		_availableModules = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:moduleDir error:nil];
		_availableModules = [_availableModules filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.nbbmodule'"]];
		_loadedModules = [[NSMutableDictionary alloc] initWithCapacity:[_availableModules count]];
		[_loaderQueue setMaxConcurrentOperationCount:[_availableModules count]];

		NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
		for (NSString* moduleName in _availableModules) {
			NSString* path = [NSString stringWithFormat:@"%@/%@", moduleDir, moduleName];
			NSBundle* moduleBundle = [NSBundle bundleWithPath:path];
			id moduleClass = moduleBundle.principalClass;

			if ([moduleClass isSubclassOfClass:[NBBModule class]]) {
				[_loaderQueue addOperationWithBlock:^{
					// load the module
					NSString* nibName = moduleBundle.infoDictionary[@"NSMainNibFile"];
					if (nibName) {
						NBBModule* module = [[moduleClass alloc] initWithWindowNibName:nibName];
						@synchronized(_loadedModules) {
							[_loadedModules setValue:module forKey:moduleBundle.bundleIdentifier];
						}
						[module release]; //retained by the dict
						[nc postNotificationName:@"NBBModuleLoaded" object:module];
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
	} else {
		@throw([NSException exceptionWithName:@"NBBIncompleteInterfaceException"
									   reason:@"Unable to load Home nib"
									 userInfo:nil]);
	}
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	// === sync prefs ===
	[self updateThemePrefs:nil];
	[_userPrefrences synchronize];

	// === destroy modules ===
	[_loaderQueue cancelAllOperations];
	@synchronized(_loadedModules) {
		[_loadedModules release];
	}

	// === destroy everything else ===
	[_loaderQueue release];
	[_availableThemes release];
	[_userPrefrences release];
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

- (NBBModule*)moduleWithName:(NSString*) moduleName loadIfNot:(BOOL) load
{
	// TODO: implement this. we should be able to search _loadedMoudlues first
	return nil;
}

- (NBBModule*)moduleWithIdentifier:(NSString*) identifier shouldLoad:(BOOL) load
{
	NBBModule* module = nil;
	@synchronized(_loadedModules) {
		module = _loadedModules[identifier];
	}
	if (!module) {
		return [self moduleWithName:[identifier pathExtension] shouldLoad:load];
	}
	return module;
}

@end
