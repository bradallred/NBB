//
//  NBBSwappableControl.h
//  Neon Boom Box
//
//  Created by Brad on 10/23/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NBBSwappableControlDelegate;

@protocol NBBSwappableControl <NSObject, NSDraggingDestination, NSDraggingSource>
@property (nonatomic, retain) IBOutlet id <NBBSwappableControlDelegate> swapDelegate;

- (void)setSwappingEnabled:(BOOL) enable;
@end

@protocol NBBSwappableControlDelegate <NSObject>
- (BOOL)controlAllowedToSwap:(NSControl <NBBSwappableControl> *) control;
@end
