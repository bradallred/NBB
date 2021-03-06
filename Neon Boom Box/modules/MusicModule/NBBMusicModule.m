//
//  NBBMusicModule.m
//  Neon Boom Box
//
//  Created by Brad on 10/18/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

#import "NBBMusicModule.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>

@implementation NBBMusicModule

- (id)initWithWindowNibName:(NSString *)windowNibName
{
	self = [super initWithWindowNibName:windowNibName];
    if (self) {
        NSLog(@"initialize music module...");
		self.moduleIcon = [NSImage imageNamed:NSImageNameBonjour];

		NSArray* dbs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.apple.iApps"][@"iTunesRecentDatabases"];
		NSURL* libraryURL = (([dbs count])) ? [NSURL URLWithString:dbs[0]] : nil;
		NSLog(@"using iTunes XML location:%@", libraryURL);

		// TODO: only reparse the library if it has changed.
		// otherwise we should load our own archived representation

		NSDictionary* library = [NSDictionary dictionaryWithContentsOfURL:libraryURL];
		if (library) {
			NSDictionary* tracks = library[@"Tracks"];
			NSDictionary* playlists = library[@"Playlists"];
			NSMutableArray* musicTracks = [NSMutableArray arrayWithCapacity:tracks.count];

			for (NSDictionary* track in tracks.allValues) {
				// Filter out podcasts/books/videos
				if (![track[@"Genre"] isEqualToString:@"Audiobook"]
					&& [track[@"Has Video"] boolValue] == NO
					&& [track[@"Podcast"] boolValue] == NO) {
					[musicTracks addObject:track];
				}
			}
			_musicLibrary = [[NSDictionary alloc] initWithObjectsAndKeys:musicTracks, @"tracks", nil];
			_artists = [_musicLibrary valueForKeyPath:@"tracks.@distinctUnionOfObjects.Artist"];
			_artists = [[_artists sortedArrayUsingSelector:@selector(compare:)] retain];
		}
		NSLog(@"music module initialization complete!");
    }

    return self;
}

- (void)dealloc
{
	[_artists release];
    [_musicLibrary release];
    [super dealloc];
}

#pragma mark TableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [_artists count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row 
{
	// Retrieve to get the @"MyView" from the pool
	// If no version is available in the pool, load the Interface Builder version
	NSTableCellView *result = [tableView makeViewWithIdentifier:@"musicTableCell" owner:self];

	// or as a new cell, so set the stringValue of the cell to the
	// nameArray value at row
	result.textField.stringValue = [_artists objectAtIndex:row];

	// return the result.
	return result;
}

@end
