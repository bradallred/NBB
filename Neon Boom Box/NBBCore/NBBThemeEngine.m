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
		_themedObjects = [[NSMutableArray alloc] init];
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

- (void)themeObject:(id <NBBThemable>) obj
{
	if ([obj conformsToProtocol:@protocol(NBBThemable)]) {
		if ([obj applyTheme:_theme]) {
			[_themedObjects addObject:obj];
		}
	}
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
