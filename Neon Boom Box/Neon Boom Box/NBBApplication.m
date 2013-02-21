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

#import "NBBApplication.h"
#import "NBBAppDelegate.h"

@implementation NBBApplication
- (id)init
{
    self = [super init];
    if (self) {
		NSLog(@"Starting NBB");
		// ??? FIXME: NSApplicationPresentationFullScreen doesn't have any effect.
		[self setPresentationOptions:NSApplicationPresentationDisableHideApplication
									| NSApplicationPresentationHideDock
#if DEBUG == 0
									| NSApplicationPresentationDisableSessionTermination
									| NSApplicationPresentationDisableForceQuit
									| NSApplicationPresentationDisableProcessSwitching
									| NSApplicationPresentationDisableAppleMenu
									| NSApplicationPresentationHideMenuBar
#endif
		 ];
		// the delegate needs to be created BEFORE the nib is loaded.
		// this is due to our need for themeing the contents of the nib

		// TODO: catch exceptions here and present an alert
        self.delegate = [[NBBAppDelegate alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self.delegate release];
    [super dealloc];
}

@end
