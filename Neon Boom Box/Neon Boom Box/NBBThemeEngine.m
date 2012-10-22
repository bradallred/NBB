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

@end
