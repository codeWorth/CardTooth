//
//  SuitCondition.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/18/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "SuitCondition.h"

@implementation SuitCondition

-(BOOL)canPlaceCard:(Card *)moveCard onCard:(Card *)destCard {
    return [moveCard.suit isEqualToString:destCard.suit];
}

@end
