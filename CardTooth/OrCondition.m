//
//  OrCondition.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/18/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "OrCondition.h"

@implementation OrCondition

-(BOOL)canPlaceCard:(Card *)moveCard onCard:(Card *)destCard {
    for (id<CardCondition> condition in self.conditions) {
        if ([condition canPlaceCard:moveCard onCard:destCard]) {
            return YES;
        }
    }
    
    return NO;
}

@end
