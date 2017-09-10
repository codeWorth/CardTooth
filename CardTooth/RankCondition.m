//
//  RankCondition.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/18/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "RankCondition.h"

@implementation RankCondition

-(instancetype)initWithComparison:(NSComparisonResult)comparison {
    if (self = [super init]) {
        self.wantedComparison = comparison;
    }
    return self;
}

-(BOOL)canPlaceCard:(Card *)moveCard onCard:(Card *)destCard {
    if (self.wantedComparison == NSOrderedSame) {
        return [moveCard.rank isEqualToString:destCard.rank];
    } else if (self.wantedComparison == NSOrderedAscending) {
        NSInteger num = [Card rankNumber:moveCard.rank];
        if (num == [[Card ranks] count] - 1) {
            return NO;
        }
        
        NSString* nextRank = [[Card ranks] objectAtIndex:num + 1];
        return [nextRank isEqualToString:destCard.rank];
    } else {
        NSInteger num = [Card rankNumber:moveCard.rank];
        if (num == 0) {
            return NO;
        }
        
        NSString* nextRank = [[Card ranks] objectAtIndex:num - 1];
        return [nextRank isEqualToString:destCard.rank];
    }
}

@end
