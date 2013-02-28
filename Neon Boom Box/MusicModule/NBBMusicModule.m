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
		}
		NSLog(@"music module initialization complete!");
    }

    return self;
}

- (void)dealloc
{
    [_musicLibrary release];
    [super dealloc];
}

@end
