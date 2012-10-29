//
//  NSActionCell+NBBSwappable.m
//  Neon Boom Box
//
//  Created by Brad on 10/25/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <objc/runtime.h>

#import "CALayer+NBBControlAnimations.h"
#import "NSActionCell+NBBSwappable.h"

static char const * const delegateTagKey = "_swapDelegate";

@implementation NSActionCell (NBBSwappable)
@dynamic swapDelegate;

- (void)setSwapDelegate:(id<NBBSwappableControlDelegate>)swapDelegate
{
	objc_setAssociatedObject(self, delegateTagKey, swapDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id <NBBSwappableControlDelegate>)swapDelegate
{
	return objc_getAssociatedObject(self, delegateTagKey);
}

- (id)initImageCell:(NSImage *)anImage
{
	self = [super initImageCell:anImage];
    if (self) {
        // subscribe to swap notifications
		NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(swapStateChanged:) name:@"NBBControlSwappingStateChanged" object:nil];
    }
    return self;
}

- (id)initTextCell:(NSString *)aString
{
	self = [super initTextCell:aString];
    if (self) {
        // subscribe to swap notifications
		NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(swapStateChanged:) name:@"NBBControlSwappingStateChanged" object:nil];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        // subscribe to swap notifications
		NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(swapStateChanged:) name:@"NBBControlSwappingStateChanged" object:nil];
    }
    return self;
}

- (void)dealloc
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
    [super dealloc];
}

- (void)setSwappingEnabled:(BOOL) enable
{
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	if (enable) {
		id <NBBSwappableControlDelegate> delegate = self.swapDelegate;
		if (delegate == nil || [delegate controlAllowedToSwap:self.controlView]) {
			// post a notification to enable swapping. either no delegate or its ok.
			[nc postNotificationName:@"NBBControlSwappingStateChanged"
							  object:self.controlView userInfo:@{ @"enabled" : @(YES) }];
			
		}
	} else {
		// post a notification to disable swapping. no need to ask delegate this is always allowed
		[nc postNotificationName:@"NBBControlSwappingStateChanged"
						  object:self.controlView userInfo:@{ @"enabled" : @(NO) }];
	}
}

- (BOOL)swappingEnabled
{
	// FIXME: this is very hackish even for me.
	return (BOOL)[self.controlView.layer animationForKey:kBTSWiggleTransformAnimation];
}

- (void)swapStateChanged:(NSNotification*) notification
{
	if ([[notification object] isKindOfClass:[self.controlView class]]) {
		if ([[[notification userInfo] objectForKey:@"enabled"] boolValue]) {
			[self.controlView.layer startJiggling];
		} else {
			[self.controlView.layer stopJiggling];
		}
	}
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
	
	BOOL result = NO;
	NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
	NSPoint currentPoint = theEvent.locationInWindow;
	BOOL done = NO;
	BOOL trackContinously = [self startTrackingAt:currentPoint inView:controlView];
	
	// Catch next mouse-dragged or mouse-up event until timeout
	BOOL mouseIsUp = NO;
	NSEvent *event;
	while (!done)
	{
		NSPoint lastPoint = currentPoint;
		
		event = [NSApp nextEventMatchingMask:(NSLeftMouseUpMask|NSLeftMouseDraggedMask)
								   untilDate:endDate
									  inMode:NSEventTrackingRunLoopMode
									 dequeue:YES];
		
		if (event)	// Mouse event
		{
			currentPoint = event.locationInWindow;
			
			// Send continueTracking.../stopTracking...
			if (trackContinously)
			{
				if (![self continueTracking:lastPoint at:currentPoint inView:controlView])
				{
					done = YES;
					[self stopTracking:lastPoint at:currentPoint inView:controlView mouseIsUp:mouseIsUp];
				}
				if (self.isContinuous)
				{
					[NSApp sendAction:self.action to:self.target from:controlView];
				}
			}
			
			mouseIsUp = (event.type == NSLeftMouseUp);
			done = done || mouseIsUp;
			
			if (untilMouseUp)
			{
				result = mouseIsUp;
			} else {
				// Check if the mouse left our cell rect
				result = NSPointInRect([controlView convertPoint:currentPoint fromView:nil], cellFrame);
				if (!result)
					done = YES;
			}
			
			if (done && result && ![self isContinuous])
				[NSApp sendAction:self.action to:self.target from:controlView];
			
		} else {
			done = YES;
			result = YES;
			BOOL swap = ![self swappingEnabled];
			[self setSwappingEnabled:swap];
			if (swap) {
				NSDraggingItem* di = nil;
				if (self.image) {
					di = [[[NSDraggingItem alloc] initWithPasteboardWriter:self.image] autorelease];
					[di setDraggingFrame:self.controlView.bounds contents:self.image];
				} else {
					NSImage* image = [[NSImage alloc] initWithSize:self.controlView.bounds.size];
					[image lockFocus];
					[self.title drawAtPoint:NSZeroPoint withAttributes:nil];
					[image unlockFocus];
					di = [[[NSDraggingItem alloc] initWithPasteboardWriter:image] autorelease];
					[di setDraggingFrame:self.controlView.bounds contents:image];
					[image release];
				}

				NSArray* items = [NSArray arrayWithObject:di];
				[self.controlView beginDraggingSessionWithItems:items event:theEvent source:self];
			}
		}
	}
	return result;
}

#pragma mark - NSDraggingSource Methods
- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
	switch(context) {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationNone;
            break;

        case NSDraggingContextWithinApplication:
        default:
            return NSDragOperationPrivate;
            break;
    }
}

- (void)draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint
{
	NSLog(@"drag began");
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
	NSLog(@"drag ended");
}

- (BOOL)ignoreModifierKeysForDraggingSession:(NSDraggingSession *)session
{
	return YES;
}

@end
