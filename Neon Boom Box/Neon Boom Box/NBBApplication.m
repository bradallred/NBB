//
//  NBBApplication.m
//  Neon Boom Box
//
//  Created by Brad on 11/1/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

#import "NBBApplication.h"
#import "NBBAppDelegate.h"

@implementation NBBApplication
- (id)init
{
    self = [super init];
    if (self) {
		NSLog(@"Starting NBB");
		// the delegate needs to be created BEFORE the nib is loaded.
		// this is due to our need for themeing the contents of the nib
        self.delegate = [[[NBBAppDelegate alloc] init] autorelease];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    [super dealloc];
}

@end
