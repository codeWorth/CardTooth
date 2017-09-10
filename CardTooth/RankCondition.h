//
//  RankCondition.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/18/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardAction.h"

@interface RankCondition : NSObject <CardCondition>

-(instancetype)initWithComparison:(NSComparisonResult)comparison;
@property (nonatomic) NSComparisonResult wantedComparison;

@end
