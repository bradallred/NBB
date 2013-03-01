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

/*
This code is based off "CALayer+WiggleAnimationAdditions" by Brian Coyner
as part of "Core-Animation-Fun-House" https://github.com/briancoyner/Core-Animation-Fun-House
Thank you, Brian.
*/

#import "CALayer+NBBControlAnimations.h"

@implementation CALayer (NBBControlAnimations)

- (void)startJiggling
{
    // For asthetics... don't reset the animations if we are already "Jiggling"... otherwise the layer jerks
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
    [rotationAnimation setDuration:0.2];
    [rotationAnimation setAutoreverses:YES];
	
    [rotationAnimation setFromValue:@(M_PI/90.0)];
    [rotationAnimation setToValue:@(-M_PI/90.0)];
    
	CGPoint center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
	self.position = center;
	self.anchorPoint = CGPointMake(0.5, 0.5);
	
    // Create the translation animation along the X axis. This gives is a slight sliding effect, which looks nice.
    CABasicAnimation *translationXAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    [translationXAnimation setRepeatCount:MAXFLOAT];
    [translationXAnimation setDuration:0.2];
	
    [translationXAnimation setAutoreverses:YES];
    [translationXAnimation setFromValue:@(self.bounds.origin.x + 2.0)];
    [translationXAnimation setToValue:@(self.bounds.origin.x - 2.0)];

    // add the animations using app-specific keys... we use these keys to "stop Jiggling".
    [self addAnimation:rotationAnimation forKey:kBTSWiggleTransformAnimation];
    [self addAnimation:translationXAnimation forKey:kBTSWiggleTransformTranslationXAnimation];
}

- (void)stopJiggling
{
    [self removeAnimationForKey:kBTSWiggleTransformAnimation];
    [self removeAnimationForKey:kBTSWiggleTransformTranslationXAnimation];
}

@end
