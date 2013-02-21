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

#import <Cocoa/Cocoa.h>

#import "NBBThemable.h"

@interface NBBTheme : NSObject
@property(nonatomic, copy) NSString* identifier;
@property(nonatomic, retain) NSMutableDictionary* prefrences;

// generic theme methods
- (NSFont*)smallFont;
- (NSFont*)normalFont;
- (NSFont*)largeFont;

- (NSColor*)cellForegroundColor;
- (NSColor*)labelForegroundColor;

- (NSColor*)cellBackgroundColor;
- (NSColor*)labelBackgroundColor;

- (NSColor*)highlightColor;

// combination for font, color and alignment
- (NSDictionary*)cellTextAttributes;
- (NSDictionary*)labelTextAttributes;

- (NSColor*)windowBackgroundColor;

// default theme preferences should supply the frames for controls
// if the theme wishes controls to have a layout diffrent from NIB
// you can also override any application default preference
- (NSDictionary*)defaultThemePrefrences;
@end
