//
//  NBBMusicModule.h
//  Neon Boom Box
//
//  Created by Brad on 10/18/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <NBBCore/NBBModule.h>

@interface NBBMusicModule : NBBModule
{
	@private
	NSDictionary* _musicLibrary;
	NSArray* _artists;
}
@end
