//
//  NBBTableView.h
//  Neon Boom Box
//
//  Created by Brad on 10/19/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NBBThemable.h"

@interface NBBTableView : NSTableView <NBBThemable>
# pragma mark - NBBThemable
- (id) initWithTheme:(NBBTheme*) theme;
- (BOOL)applyTheme:(NBBTheme*) theme;
@end
