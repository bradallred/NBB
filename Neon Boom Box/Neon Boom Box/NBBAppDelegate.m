//
//  NBBAppDelegate.m
//  Neon Boom Box
//
//  Created by Brad on 10/18/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

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
