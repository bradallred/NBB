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

			BOOL isBook = NO;
			BOOL isVideo = NO;

			for (NSDictionary* track in tracks.allValues) {
				// TODO: import apropriate tracks into an internal library
			}
		}
    }

    return self;
}

@end
