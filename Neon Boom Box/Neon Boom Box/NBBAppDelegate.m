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
