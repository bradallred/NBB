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

#import <Foundation/Foundation.h>
#import <NBBCore/NBBWindow.h>
#import <NBBCore/NBBTheme.h>
#import "NBBThemable.h"
/*
 The current plan for the theming engine:
 * themes will be loadable bundles (NSBundle) containing a subclass of NBBTheme ("abstract" base class)
 * module interfaces are built in IB
 * the theme engine will be "File owner" of all NIBs
 * NBB control subclasses (adopting NBBThemable protocol and category) act as "proxy" objects.
 * upon initializing an NBBThemable control the category will ask the engine
 (which in turn gets info from the active NBBTheme)
 which subclass (if any) should be initialized in its place (using the protocol method initWithTheme)
 * the special initializer passes the NBBTheme instance to the control
 the control uses this instance to configure its customizeable parameters
 
 This way themes can specify (if they choose) their own subclasses to achieve greater customization then
 our basic theming API will supply.
 
 The theme engine will use "Key Value Coding" to allow themes to create their own controls and wire them to module methods
 using cocoa bindings.
*/

@interface NBBThemeEngine : NSObject
{
@private
	NSMutableSet* _themedObjects;
}
@property(assign) IBOutlet NBBWindow* window;
@property(nonatomic, readonly) NBBTheme* theme;

+ (NBBThemeEngine*)sharedThemeEngine;

- (Class <NBBThemable>)classReplacementForThemableClass:(Class <NBBThemable>) cls;
- (BOOL)themeObject:(id <NBBThemable>) obj;
- (void)swapView:(NSView*) source withView:(NSView*) dest persist:(BOOL) persist;

/*
 This method will iterate the _themedObjects set and send an applyTheme message to each
*/
- (void)applyTheme:(NBBTheme*) theme;
@end
