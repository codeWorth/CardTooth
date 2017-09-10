//
//  Card.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/7/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "Card.h"

@implementation Card

+(NSArray*)ranks {
    return @[
             @"2",
             @"3",
             @"4",
             @"5",
             @"6",
             @"7",
             @"8",
             @"9",
             @"10",
             @"jack",
             @"queen",
             @"king",
             @"ace"
             ];
}

+(NSArray*)suits {
    return @[
             @"clubs",
             @"diamonds",
             @"hearts",
             @"spades"
             ];
}

+(NSInteger)rankNumber:(NSString *)rank {
    return [[Card ranks] indexOfObject:rank];
}

+(NSInteger)suitNumber:(NSString*)suit {
    return [[Card suits] indexOfObject:suit];
}

-(instancetype)initWithSuit:(NSString*)suit andRank:(NSString*)rank {
    if (self = [super init]) {
        self.rank = rank;
        self.suit = suit;
    }
    return self;
}

-(NSString*)imageName {
    return [NSString stringWithFormat:@"%@_of_%@.png", self.rank, self.suit];
}

-(NSString*)description {
    return @"fat";
}

@end
