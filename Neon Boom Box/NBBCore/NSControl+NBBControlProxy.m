//
//  NSControl+NBBControlProxy.m
//  Neon Boom Box
//
//  Created by Brad on 10/21/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

#import "NSControl+NBBControlProxy.h"
#import "NBBThemeEngine.h"

@implementation NSControl (NBBControlProxy)

+ (id)allocWithZone:(NSZone *)zone
{
	NBBThemeEngine* themeEngine = [NBBThemeEngine sharedThemeEngine];
	self = [themeEngine classReplacementForThemableClass:self];

	return [super allocWithZone:zone];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NBBThemeEngine* themeEngine = [NBBThemeEngine sharedThemeEngine];
		[themeEngine themeObject:(id <NBBThemable>)self];
    }
    return self;
}
@end
