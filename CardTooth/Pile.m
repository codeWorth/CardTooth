//
//  PileConfig.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/17/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "Pile.h"

@interface Pile ()

@property (nonatomic, strong) CardDeck* deck;

@property (nonatomic) NSInteger _startingSize;

@end

@implementation Pile

-(instancetype)initFaceUp:(BOOL)faceUp {
    if (self = [super init]) {
        self.deck = [[CardDeck alloc] init];
        self._startingSize = -1;
        self.faceUp = faceUp;
    }
    return self;
}

-(instancetype)initWithSize:(NSInteger)size faceUp:(BOOL)faceUp {
    if (self = [super init]) {
        self.deck = [[CardDeck alloc] init];
        self._startingSize = size;
        self.faceUp = faceUp;
    }
    return self;
}

-(CardDeck*)deck {
    return self.deck;
}

-(void)addCard:(Card *)card {
    [self.deck addCard:card];
}

-(void)moveTopCardToPile:(Pile *)pile {
    [pile addCard:[self.deck popTopCard]];
}

-(void)resetWithCards:(NSArray<Card *> *)cards {
    [self.deck addCards:cards];
}

-(NSInteger)startingSize {
    return self._startingSize;
}

@end
