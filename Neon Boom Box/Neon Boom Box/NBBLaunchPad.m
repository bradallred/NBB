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
    [_moduleCells release];
	free(_cellFrames);
    [super dealloc];
}

- (NSCell*) addCellForModule:(NBBModule*) module
{
	// create a cell representing the module
	NSActionCell* cell = [[[[self class] cellClass] alloc] initImageCell:module.moduleIcon];
	cell.target = module;
	// TODO: set the cell action to whatever our selector for running the module is when implemented
	[_moduleCells addObject:cell];
	// now add a cell frame for the new module
	_cellFrames = realloc(_cellFrames, sizeof(NSRect) * _moduleCells.count);
	NSRect cellFrame = [self frameForCellIndex:[_moduleCells indexOfObject:cell]];
	_cellFrames[_moduleCells.count - 1] = cellFrame;
	[self setNeedsDisplayInRect:cellFrame];
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

- (NSImage*)imageForCell:(NSCell*)cell highlighted:(BOOL) highlight
{
	NSUInteger index = [_moduleCells indexOfObject:cell];
	if (index != NSNotFound) {
		self.cell = cell;
		return [super imageForCell:cell highlighted:highlight];
	}
	// cell doesnt belong to this control!
	return nil;
}

- (void)drawRect:(NSRect)dirtyRect
{
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
	NSButtonCell* cell = nil;
	NSPoint mp = [self convertPoint:theEvent.locationInWindow fromView:nil];
	for (NSUInteger i = 0; i < _moduleCells.count; i++) {
		if ( [self mouse:mp inRect:_cellFrames[i]] ) {
			cell = _moduleCells[i];
		}
	}
	if (cell) {
		self.cell = cell;
		[super mouseDown:theEvent];
	}
}

@end
