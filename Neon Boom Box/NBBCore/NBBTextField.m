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

#import "NBBTextField.h"

@implementation NBBTextField

# pragma mark - NBBThemable
- (id)initWithTheme:(NBBTheme*) theme
{
	CGRect frame = {}; // TODO: implement a way to get frame from theme
	self = [self initWithFrame:frame]; // initWithFrame is the designated initializer for NSControl
	if (self) {
		// special theme initialization will go here
		// could just call applyTheme
	}
	return self;
}

- (BOOL)applyTheme:(NBBTheme*) theme
{
	return YES;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
