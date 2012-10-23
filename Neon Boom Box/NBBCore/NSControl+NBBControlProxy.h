//
//  NSControl+NBBControlProxy.h
//  Neon Boom Box
//
//  Created by Brad on 10/21/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
This category exists to intercept alloc calls for controls adopting the NBBThemable protocol.
The goal is to allocate and return overriding theme specific subclasses instead
*/

@interface NSControl (NBBControlProxy)
+ (id)allocWithZone:(NSZone *)zone;
- (void)viewWillMoveToWindow:(NSWindow *)newWindow;
@end
