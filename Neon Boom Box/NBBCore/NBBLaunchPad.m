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

#import "NBBLaunchPad.h"

#import <NBBCore/NBBButton.h>

#import <NBBCore/CALayer+NBBControlAnimations.h>

@implementation NBBLaunchPad

+ (void)initialize
{
	[super initialize];
	[self setCellClass:[NBBButtonCell class]];
}

- (void)finalizeInit
{
	_moduleCells = [[NSMutableArray alloc] init];
	_cellFrames = malloc(sizeof(NSRect));
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
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
	[_animationLayers release];
    [_moduleCells release];
	free(_cellFrames);
    [super dealloc];
}

- (NSCell*)cellAtPoint:(NSPoint) point
{
	for (NSUInteger i = 0; i < _moduleCells.count; i++) {
		if ( [self mouse:point inRect:_cellFrames[i]] ) {
			return _moduleCells[i];
		}
	}
	return nil;
}

- (NSCell*) addCellForModule:(NBBModule*) module
{
	// TODO: take into account when swapping is enabled!

	// create a cell representing the module
	NSButtonCell* cell = [[[[self class] cellClass] alloc] initImageCell:module.moduleIcon];
	cell.target = module;
	// TODO: consider the possibility of 2 buttons for the same module
	// what should we do? I'm tempted to convert to a dict to prevent this.
	cell.identifier = [self.identifier stringByAppendingFormat:@"-%@", module.identifier];
	// TODO: set the cell action to whatever our selector for running the module is when implemented
	[_moduleCells addObject:cell];
	// now add a cell frame for the new module
	_cellFrames = realloc(_cellFrames, sizeof(NSRect) * _moduleCells.count);
	NSRect cellFrame = [self frameForCellIndex:[_moduleCells indexOfObject:cell]];
	_cellFrames[_moduleCells.count - 1] = cellFrame;
	[self setNeedsDisplayInRect:cellFrame];

	if (![NSThread isMainThread]) {
		// if running on backround thread we need to wait for animations before terminating
		[CATransaction flush];
	}

	return [cell autorelease];
}

- (NSRect)frameForCell:(NSCell*)cell
{
	return [self frameForCellIndex:[_moduleCells indexOfObject:cell]];
}

- (NSRect)frameForCellIndex:(NSUInteger) cellIndex
{
	NSRect rect = NSZeroRect;
	if (cellIndex && cellIndex != NSNotFound) {
		// TODO: actually implement an origin
		rect.origin = _cellFrames[cellIndex - 1].origin;
		rect.origin.x += _cellFrames[cellIndex - 1].size.width;
	}
	rect.size = [_moduleCells[cellIndex] cellSize];

	return rect;
}

- (NSDraggingSession*)beginDraggingSessionWithDraggingCell:(NSCell <NSDraggingSource> *)cell event:(NSEvent*) theEvent
{
	_dragCell = cell;

	assert(cell.identifier);
	CALayer* layer = _animationLayers[cell.identifier];

	if (layer) {
		layer.hidden = YES;
	}

	return [super beginDraggingSessionWithDraggingCell:cell event:theEvent];
}

- (NSImage*)imageForCell:(NSCell*)cell highlighted:(BOOL) highlight
{
	NSUInteger index = [_moduleCells indexOfObject:cell];
	if (index != NSNotFound) {
		//self.cell = cell;
		//return [super imageForCell:cell highlighted:highlight];

		BOOL isHighlighted = [cell isHighlighted];
		[cell setHighlighted:highlight];

		NSRect cellFrame = [self frameForCell:cell];
		NSImage* image = [[NSImage alloc] initWithSize:cellFrame.size];
		[image lockFocus];
		cellFrame.origin = NSZeroPoint;
		[cell drawWithFrame:cellFrame inView:self];
		[image unlockFocus];

		// restore the cell highlight state
		[cell setHighlighted:isHighlighted];

		return [image autorelease];
	}
	// cell doesnt belong to this control!
	return nil;
}

- (void)drawRect:(NSRect)dirtyRect
{
	// if we are dragging we dont need to draw cells since
	// animation layers are present
	if (_animationLayers) return;
    for (NSActionCell* cell in _moduleCells) {
		// draw each cell if it overlaps dirtyRect
		NSRect cellFrame = _cellFrames[ [_moduleCells indexOfObject:cell] ];
		if ([self needsToDrawRect:cellFrame]) {
			// rects intersect so draw this cell.
			[cell drawWithFrame:cellFrame inView:self];
		}
	}
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint mp = [self convertPoint:theEvent.locationInWindow fromView:nil];
	NSCell* cell = [self cellAtPoint:mp];

	if (cell) {
		if ([self swappingEnabled]) {
			// highlight 
			CALayer* layer = _animationLayers[cell.identifier];
			layer.contents = [self imageForCell:cell highlighted:YES];
		}
		self.cell = cell; //need to set this for [super mouseDown]
		[super mouseDown:theEvent];
	}
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender
{
	NSPoint mp = [self convertPoint:[sender draggingLocation] fromView:nil];
	NSCell* cell = [self cellAtPoint:mp];

	if (cell == nil || cell == _dragCell) {
		return NSDragOperationNone;
	}

	CALayer* layer = _animationLayers[cell.identifier];
	layer.contents = [self imageForCell:cell highlighted:YES];
	return [cell draggingEntered:sender];
}

- (void)draggingEnded:(id < NSDraggingInfo >)sender
{
	assert(_dragCell);
	CALayer* layer = _animationLayers[_dragCell.identifier];
	layer.contents = [self imageForCell:_dragCell highlighted:NO];

	// purpousely prevent display!
	[self setNeedsDisplay:NO];
}

- (void)concludeDragOperation:(id < NSDraggingInfo >)sender
{

}

// FIXME: this is a dirty hack!
// we prevent hiding because the drag animation window will try to hide us,
// but we really only want one cell hidden.
// obviously this breaks anything that actually wants to hide us
- (void)setHidden:(BOOL)flag
{
	if (!_dragCell) {
		[super setHidden:flag];
	} else if (flag == NO) {

		[_dragCell setHighlighted:NO];

		CALayer* layer = _animationLayers[_dragCell.identifier];
		layer.hidden = NO;

		_dragCell = nil;
		[super setHidden:NO];
		//[self setNeedsDisplay:YES];
	}
}

- (BOOL)swappingEnabled
{
	return (BOOL)_animationLayers;
}

- (void)setSwappingEnabled:(BOOL) enable
{
	// TODO: take delegate into consideration
	// should probably return a BOOL since the delegate will be able to block

	if (enable && !_animationLayers) {
		self.wantsLayer = YES;
		self.layer.sublayers = nil;
		//[self.layer stopJiggling];

		// setup core animation layers for all the cells
		_animationLayers = [[NSMutableDictionary alloc] initWithCapacity:[_moduleCells count]];

		for (NSCell* cell in _moduleCells) {
			CALayer* newLayer = [CALayer layer];
			newLayer.frame = [self frameForCell:cell];
			newLayer.contents = [self imageForCell:cell highlighted:NO];
			[newLayer startJiggling];
			[self.layer addSublayer:newLayer];
			assert(cell.identifier);
			_animationLayers[cell.identifier] = newLayer;
		}

		[self setNeedsDisplay:YES];
	} else if (enable == NO) {
		// destroy the layers. easier to setup from scratch each time then try to keep
		// layers and cells kept in sync dynamically
		self.layer.sublayers = nil;
		[_animationLayers release];
		_animationLayers = nil;
	}
}

@end
