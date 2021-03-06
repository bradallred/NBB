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

#import <NBBCore/NBBLaunchpad.h>
#import <NBBCore/NBBThemeEngine.h>

@interface NBBAppDelegate : NSObject <NSApplicationDelegate>
{
	@private
	NSMutableDictionary* _loadedModules;
	NSOperationQueue* _loaderQueue;
}
@property(nonatomic, retain) IBOutlet NBBWindow* homeWindow;
@property(nonatomic, retain) IBOutlet NBBLaunchPad* launchpad;

@property(readonly, nonatomic) NBBThemeEngine* themeEngine;
@property(readonly, nonatomic) NSDate* dateTime;
@property(readonly, nonatomic) NSUserDefaults* userPrefrences;
@property(readonly, nonatomic) NSArray* availableThemes;
@property(readonly, nonatomic) NSArray* availableModules;

- (NBBTheme*)themeWithName:(NSString*) themeName;
- (NBBTheme*)themeWithIdentifier:(NSString*) identifier;

- (NBBModule*)moduleWithName:(NSString*) moduleName shouldLoad:(BOOL) load;
- (NBBModule*)moduleWithIdentifier:(NSString*) identifier shouldLoad:(BOOL) load;

@end
