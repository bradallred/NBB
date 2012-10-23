//
//  NBBAppDelegate.h
//  Neon Boom Box
//
//  Created by Brad on 10/18/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <NBBCore/NBBThemeEngine.h>

@interface NBBAppDelegate : NSObject <NSApplicationDelegate>
@property(readonly, assign) NBBThemeEngine* themeEngine;
@end
