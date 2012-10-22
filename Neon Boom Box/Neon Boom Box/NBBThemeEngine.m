//
//  NBBThemeEngine.m
//  Neon Boom Box
//
//  Created by Brad on 10/19/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

#import "NBBThemeEngine.h"

@implementation NBBThemeEngine

// singleton pattern
#pragma mark - Singleton

static NBBThemeEngine* _sharedThemeEngine = nil;

+ (NBBThemeEngine*)sharedThemeEngine
{
    if (_sharedThemeEngine == nil) {
        _sharedThemeEngine = [[super allocWithZone:NULL] init];
    }
    return _sharedThemeEngine;
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
		_themedObjects = [[NSMutableArray alloc] init];
        // get the current theme from user defaults
		// if the theme is not set or no longer exists
		// we will apply the first theme found
		NSString* themeName = [[NSUserDefaults standardUserDefaults] stringForKey:@"NBBActiveTheme"];
		NSString* themePath = [[NSBundle mainBundle] pathForResource:themeName ofType:@"nbbtheme" inDirectory:@"Themes"];
		if (!themePath) {
			// just grab the first nbbtheme bundle
			NSString* themeDir = [NSString stringWithFormat:@"%@/Themes", [[NSBundle mainBundle] bundlePath]];
			NSArray* themes = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:themeDir error:nil];
			themes = [themes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.nbbtheme'"]];
			themePath = [themes objectAtIndex:0];
		}
		NSBundle* themeBundle = [NSBundle bundleWithPath:themePath];
		NBBTheme* theme = [[NBBTheme alloc] initWithBundle:themeBundle];
		[self applyTheme:theme];
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

@end
