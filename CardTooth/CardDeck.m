//
//  CardDeck.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/7/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "CardDeck.h"

@interface CardDeck ()

@property (nonatomic, strong) NSMutableArray<Card*>* deck;

@end

@implementation CardDeck

-(instancetype)init {
    if (self = [super init]) {
        [self resetDeck];
    }
    return self;
}

-(Card*)topCard {
    return [self.deck lastObject];
}

-(NSArray<Card*>*)cards {
    return [self.deck copy];
}

-(Card*)popTopCard {
    Card* topCard = [self topCard];
    [self.deck removeLastObject];
    return topCard;
}

-(NSArray<Card*>*)top:(NSInteger)cards {
    NSMutableArray* topCards = [[NSMutableArray alloc] init];
    for (int i = 0; i < cards; i++) {
        Card* thisCard = [self popTopCard];
        if (thisCard == nil) {
            return topCards;
        }
        [topCards addObject:thisCard];
    }
    return topCards;
}

-(void)resetDeck {
    [self emptyDeck];
    
    NSMutableArray* temp = [NSMutableArray array];
    for (NSString* suit in [Card suits]) {
        for (NSString* rank in [Card ranks]) {
            Card* newCard = [[Card alloc] initWithSuit:suit andRank:rank];
            [temp addObject:newCard];
        }
    }
    
    NSInteger items = [temp count];
    NSInteger i = 0;
    while (i < items) {
        NSInteger rand = arc4random_uniform((int)[temp count]);
        [self.deck addObject:temp[rand]];
        [temp removeObjectAtIndex:rand];
        i++;
    }
}

-(void)addCard:(Card *)card {
    [self.deck addObject:card];
}

-(void)addCards:(NSArray<Card *> *)cards {
    for (Card* card in cards) {
        [self addCard:card];
    }
}

-(NSInteger)numberOfRank:(NSString *)rank {
    NSInteger num = 0;
    for (Card* card in self.cards) {
        if ([card.rank isEqualToString:rank]) {
            num++;
        }
    }
    
    return num;
}

-(void)emptyDeck {
    self.deck = [NSMutableArray array];
}


@end
