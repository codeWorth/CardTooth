//
//  GameRules.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/18/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PileGroup.h"
#import "CardAction.h"

@protocol WinCondition <NSObject>

-(BOOL)wonWithPile:(Pile*)pile;

@end

@interface RoundGameRules : NSObject

@property (nonatomic, strong) NSMutableArray<CardAction*>* actionsEachRound;
@property (nonatomic, strong) PileGroup* startingSetup;
@property (nonatomic, strong) id<WinCondition> winCondition;

@end
