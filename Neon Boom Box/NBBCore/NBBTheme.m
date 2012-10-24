//
//  NBBTheme.m
//  Neon Boom Box
//
//  Created by Brad on 10/18/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

#import "NBBTheme.h"

@implementation NBBTheme

- (NSFont*)smallFont
{
	return [NSFont controlContentFontOfSize:14.0];
}

- (NSFont*)normalFont
{
	return [NSFont controlContentFontOfSize:24.0];
}

- (NSFont*)largeFont
{
	return [NSFont controlContentFontOfSize:32.0];
}

@end
