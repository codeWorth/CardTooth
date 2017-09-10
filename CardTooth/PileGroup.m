//
//  PileGroup.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/17/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "PileGroup.h"

@interface PileGroup ()

@property (nonatomic) NSInteger _startingSize;

@end

@implementation PileGroup

-(instancetype)initWithStartinSize:(NSInteger)startingSize {
    if (self = [super init]) {
        self.piles = [NSMutableArray array];
        self._startingSize = startingSize;
    }
    return self;
}

-(void)resetWithCards:(NSArray<Card *> *)cards {
    NSMutableArray* def = [NSMutableArray array];
    NSMutableArray* noDef = [NSMutableArray array];
    NSMutableArray* deck = [NSMutableArray arrayWithArray:cards];
    
    for (Pile* pile in self.piles) {
        if (pile.startingSize > -1) {
            [def addObject:pile];
        } else {
            [noDef addObject:pile];
        }
    }
    
    NSMutableArray* miniDeck = [NSMutableArray array];
    for (id<Resetable> pile in def) {
        for(int i = 0; i < [pile startingSize]; i++) {
            [miniDeck addObject:[deck lastObject]];
            [deck removeLastObject];
        }
        [pile resetWithCards:miniDeck];
        [miniDeck removeAllObjects];
    }
    
    for (int i = 0; i < [noDef count]; i++) {
        NSInteger deckSize = [deck count] / ([noDef count] - i);
        Pile* pile = (Pile*)[noDef objectAtIndex:i];
        
        for (int j = 0; i < deckSize; i++) {
            [miniDeck addObject:[deck lastObject]];
            [deck removeLastObject];
        }
        
        [pile resetWithCards:miniDeck];
        [miniDeck removeAllObjects];
    }    
}

-(NSInteger)startingSize {
    return self._startingSize;
}


@end
