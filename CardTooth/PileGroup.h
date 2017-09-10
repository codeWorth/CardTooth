//
//  PileGroup.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/17/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pile.h"
#import "Card.h"

@interface PileGroup : NSObject <Resetable>

-(instancetype)initWithStartinSize:(NSInteger)startingSize;

@property (nonatomic, strong) NSMutableArray<id<Resetable>>* piles;
-(NSInteger)startingSize;

-(void)resetWithCards:(NSArray<Card*>*)cards;

@end
