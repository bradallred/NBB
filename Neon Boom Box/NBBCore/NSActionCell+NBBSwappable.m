/* Neon Boom Box - In-car entertainment front-end
 * Copyright (C) 2012 Brad Allred
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

#import <objc/runtime.h>

#import "CALayer+NBBControlAnimations.h"
#import "NSActionCell+NBBSwappable.h"

#import "NBBDragAnimationWindow.h"

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

- (void)finalizeInit
{
	// subscribe to swap notifications
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(swapStateChanged:) name:@"NBBControlSwappingStateChanged" object:nil];

	// this is a bit of a hac, but the easiest way to make the control dragging work.
	// force the control to accept image drags.
	// the control will forward us the drag destination events via our NBBControlProxy category
	[self.controlView registerForDraggedTypes:[NSImage imagePasteboardTypes]];
}

// NSCell docs say we have 3 designated initializers.
// be sure we add finalizeInit to all of them
#pragma mark - Inits

- (id)initImageCell:(NSImage *)anImage
{
	self = [super initImageCell:anImage];
    if (self) {
		[self finalizeInit];
    }
    return self;
}

- (id)initTextCell:(NSString *)aString
{
	self = [super initTextCell:aString];
    if (self) {
        [self finalizeInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self finalizeInit];
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
	NSView* cv = self.controlView;
	if ([[notification object] isKindOfClass:[cv class]]) {
		if ([[[notification userInfo] objectForKey:@"enabled"] boolValue]) {
			[cv.layer startJiggling];
		} else {
			[cv.layer stopJiggling];
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

	// Catch next mouse-dragged or mouse-up event until timeout (or drag while control is dragable)
	BOOL mouseIsUp = NO;
	NSEvent *event;
	while (!done)
	{
		NSPoint lastPoint = currentPoint;
		
		event = [NSApp nextEventMatchingMask:(NSLeftMouseUpMask|NSLeftMouseDraggedMask)
								   untilDate:endDate
									  inMode:NSEventTrackingRunLoopMode
									 dequeue:YES];

		BOOL swap = [self swappingEnabled];
		if (event && !swap)
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

			if (!event) {
				// if there is no event then the timer expired and we should toggle swapping
				swap = !swap;
				[self setSwappingEnabled:swap];
			}

			if (swap) {
				// this bit-o-magic executes on either a drag event or immidiately following timer expiration
				// this initiates the control drag event using NSDragging protocols
				NSView* cv = self.controlView;
				NSBitmapImageRep* rep = [cv bitmapImageRepForCachingDisplayInRect:cv.bounds];
				NSImage* image = [[NSImage alloc] initWithSize:rep.size];

				[cv cacheDisplayInRect:cv.bounds toBitmapImageRep:rep];
				[image addRepresentation:rep];

				NSDraggingItem* di = [[[NSDraggingItem alloc] initWithPasteboardWriter:image] autorelease];
				[di setDraggingFrame:cv.bounds contents:image];
				[image release];
				NSArray* items = [NSArray arrayWithObject:di];

				NSDraggingSession* session = [cv beginDraggingSessionWithItems:items event:theEvent source:self];
				// we must NOT let the session handle the cancel/fail animation
				// if we did we would have an ugly fade out and sudden appearance of the control
				// we will fake this animation ourselves. see +initialize and NSDraggingSource methods
				session.animatesToStartingPositionsOnCancelOrFail = NO;
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
	NBBDragAnimationWindow* dw = [NBBDragAnimationWindow sharedAnimationWindow];
	NSView* cv = self.controlView;

	NSImage* image = [[NSImage alloc] initWithPasteboard:session.draggingPasteboard];
	[dw setupDragAnimationWith:cv usingDragImage:image];
	[image release];
	[dw setFrame:[cv.window convertRectToScreen:cv.frame] display:NO];

}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
	if (operation == NSDragOperationNone) {
		NBBDragAnimationWindow* dw = [NBBDragAnimationWindow sharedAnimationWindow];
		NSRect frame = dw.frame;

		[dw setFrameTopLeftPoint:screenPoint];
		[dw animateToFrame:frame];
	}
}

- (BOOL)ignoreModifierKeysForDraggingSession:(NSDraggingSession *)session
{
	return YES;
}

#pragma mark - NSDraggingDestination Methods
- (BOOL)wantsPeriodicDraggingUpdates
{
	return NO;
}

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
	if ([self swappingEnabled]) {
		[self setHighlighted:YES];
		return NSDragOperationPrivate;
	}
	return NSDragOperationNone;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
	[self setHighlighted:NO];
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
	return YES;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
	return YES;
}

- (void)concludeDragOperation:(id < NSDraggingInfo >)sender
{
	NSView* cv = self.controlView;
	NSView* source = [(NSActionCell*)[sender draggingSource] controlView];
	NSRect srcFrame = source.frame;
	NSRect dstFrame = cv.frame;

	assert(cv && source && cv != source);

	NSLog(@"swapping %@:{%f,%f} with %@:{%f,%f}",
		  cv, dstFrame.origin.x, dstFrame.origin.y,
		  source, srcFrame.origin.x, srcFrame.origin.y);

	[self setHighlighted:NO];

	// FIXME: if the user is quick and drags a control while it is still animating into position
	// the frame wont be updated yet causing the dragged control to end up in the wrong location
	// possible solution would be to disable the control during swap animation and re-enable after
	// problem with that solution might be that we want disabled controls to be swappable too
	// ignoring for now since normal use cases shouldnt trigger this

	// we need to obtain the coordinates for the drag image representing the source control
	NSPoint startPt = [sender draggedImageLocation];
	NSRect startFrame = source.frame;
	startFrame.origin = startPt;
	[source setFrame:startFrame]; // move the control before making it visible (no animation)
	[source setHidden:NO];

	// !!!: Unexplicably this frame swap can become undone by evil forces of the superview
	// example: if the TextField clock is bound to the dateTime of the AppDelegate and has the same
	// superview as our swap buttons then each timer tick the frames will mysteriously reset to
	// original values. However, if the clock is moved to a new subview of the superview then
	// everything works fine.
	// I have no explaination or theories why this happens. somebody please tell me :p

	// animate both controls to the others original frame
	[[cv animator] setFrame:srcFrame];
	[[source animator] setFrame:dstFrame];
}

@end
