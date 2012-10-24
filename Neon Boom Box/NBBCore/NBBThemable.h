//
//  NBBThemable.h
//  Neon Boom Box
//
//  Created by Brad on 10/19/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NBBTheme;

@protocol NBBThemable <NSObject>
- (id) initWithTheme:(NBBTheme*) theme;
- (BOOL) applyTheme:(NBBTheme*) theme;
@end
