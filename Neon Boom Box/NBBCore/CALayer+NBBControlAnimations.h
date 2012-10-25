//
//  CALayer+NBBControlAnimations.h
//  Neon Boom Box
//
//  Created by Brad on 10/23/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

static NSString * const kBTSWiggleTransformAnimation = @"BTSWiggleTransformAnimation";
static NSString * const kBTSWiggleTransformTranslationXAnimation = @"BTSWiggleTransformTranslationXAnimation";

@interface CALayer (NBBControlAnimations)
- (void)startJiggling;
- (void)stopJiggling;
@end
