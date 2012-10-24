//
//  CALayer+NBBControlAnimations.m
//  Neon Boom Box
//
//  Created by Brad on 10/23/12.
//  Copyright (c) 2012 NBB. All rights reserved.
//

/*
This code is based off "CALayer+WiggleAnimationAdditions" by Brian Coyner
as part of "Core-Animation-Fun-House" https://github.com/briancoyner/Core-Animation-Fun-House
Thank you, Brian.
*/

#import "CALayer+NBBControlAnimations.h"

@implementation CALayer (NBBControlAnimations)
static NSString * const kBTSWiggleTransformAnimation = @"BTSWiggleTransformAnimation";
static NSString * const kBTSWiggleTransformTranslationXAnimation = @"BTSWiggleTransformTranslationXAnimation";

- (void)startWiggling
{
    // For asthetics... don't reset the animations if we are already "wiggling"... otherwise the layer jerks
    if ([self animationForKey:kBTSWiggleTransformAnimation] != nil && [self animationForKey:kBTSWiggleTransformTranslationXAnimation] != nil) {
        return;
    }
    
    // NOTE: We need two animations because we need different time scales to achieve the wiggle affect implemented
    //       by this method. The rotation animation happens every 0.1 seconds. The translation animation happens every 0.2 seconds.
    //       This means that we are _not_ able to create a single transformation matrix (rotation and translation) because then we
    //       would be bound to a single time scale.
    
    // Create the rotation animation - a very small angle is all we need to achieve a wiggle effect.
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [rotationAnimation setRepeatCount:MAXFLOAT];
    [rotationAnimation setDuration:0.1];
    [rotationAnimation setAutoreverses:YES];
	
    [rotationAnimation setFromValue:[NSNumber numberWithFloat:(float) (M_PI/100.0)]];
    [rotationAnimation setToValue:[NSNumber numberWithFloat:(float) (-M_PI/100.0)]];
    
    // Create the translation animation along the X axis. This gives is a slight sliding effect, which looks nice.
    CABasicAnimation *translationXAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    [translationXAnimation setRepeatCount:MAXFLOAT];
    [translationXAnimation setDuration:0.2];
	
    [translationXAnimation setAutoreverses:YES];
    [translationXAnimation setFromValue:[NSNumber numberWithFloat:[self bounds].origin.x + 2.0]];
    [translationXAnimation setToValue:[NSNumber numberWithFloat:[self bounds].origin.x - 2.0]];
	
    // add the animations using app-specific keys... we use these keys to "stop wiggling".
    [self addAnimation:rotationAnimation forKey:kBTSWiggleTransformAnimation];
    [self addAnimation:translationXAnimation forKey:kBTSWiggleTransformTranslationXAnimation];
}

- (void)stopWiggling
{
    [self removeAnimationForKey:kBTSWiggleTransformAnimation];
    [self removeAnimationForKey:kBTSWiggleTransformTranslationXAnimation];
}
@end
