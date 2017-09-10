//
//  OrCondition.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/18/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AndCondition.h"

@interface OrCondition : NSObject <CardCondition>

@property (nonatomic, strong) NSMutableArray<id<CardCondition>>* conditions;

@end
