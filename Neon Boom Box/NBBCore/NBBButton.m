//
//  NBBButton.m
//  Neon Boom Box
//
//  Created by Brad on 10/19/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

#import "NBBButton.h"

@interface NBBButtonCell : NSButtonCell

@end

@implementation NBBButtonCell

@end

@implementation NBBButton

+ (void)initialize
{
	// force custom button cell class
	[self setCellClass:[NBBButtonCell class]];
}

# pragma mark - Initializers
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

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        if (![[self cell] isKindOfClass:[NBBButtonCell class]])
		{
			// force custom button cell class for NIB archived buttons
			NSImage* image = [self image];
			[self setCell:[[[NBBButtonCell alloc] initImageCell:image] autorelease]];
			[[self cell] setControlSize:NSRegularControlSize];
		}
    }
    return self;
}

- (BOOL)applyTheme:(NBBTheme*) theme
{
	return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
