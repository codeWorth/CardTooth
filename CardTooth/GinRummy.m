//
//  GinRummy.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/27/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "GinRummy.h"

#define HAND_SIZE 10

@implementation GinRummy

-(instancetype)initWithDelegate:(id<GinRummyDelegate>)delegate {
    if (self = [super init]) {
        self.cardDeck = [[CardDeck alloc] init];
        self.discardDeck = [[CardDeck alloc] init];
        [self.discardDeck emptyDeck];
        
        self.player1Turn = YES;
        if (arc4random_uniform(2) == 0) {
            self.player1Turn = NO;
        }
        
        self.delegate = delegate;
    }
    return self;
}

-(void)beginGame {
    [self.delegate player1Hand:[self.cardDeck top:HAND_SIZE]];
    [self.delegate player2Hand:[self.cardDeck top:HAND_SIZE]];
    
    [self.discardDeck addCard:[self.cardDeck popTopCard]];
    [self.delegate updateDiscard];
    [self.delegate updateTurn];
}

-(Card *)topDiscard {
    return [self.discardDeck topCard];
}

-(BOOL)canGetCardFromCards:(BOOL)p1 {
    return p1 == self.player1Turn && !self.p1GotCard;

}
-(Card*)getCardFromCards:(BOOL)p1 {
    if ([self canGetCardFromCards:p1]) {
        if (p1) {
            self.p1GotCard = YES;
        } else {
            self.p2GotCard = YES;
        }
        return [self.cardDeck popTopCard];
    }
    return nil;
}


-(BOOL)canGetCardFromDiscard:(BOOL)p1 {
    return p1 == self.player1Turn && !self.p1GotCard;
}
-(Card*)getCardFromDiscards:(BOOL)p1 {
    if ([self canGetCardFromDiscard:p1]) {
        if (p1) {
            self.p1GotCard = YES;
        } else {
            self.p2GotCard = YES;
        }
        Card* card = [self.discardDeck popTopCard];
        [self.delegate updateDiscard];
        return card;
    }
    return nil;
}

-(BOOL)canTakeCardFromHand:(BOOL)p1 {
    if (self.player1Turn != p1) {
        return false;
    }
    
    if (p1 == YES) {
        return self.p1GotCard;
    } else {
        return self.p2GotCard;
    }
}
-(BOOL)canPutCardInDiscard:(BOOL)p1 {
    if (self.player1Turn != p1) {
        return false;
    }
    
    if (p1 == YES) {
        return self.p1GotCard;
    } else {
        return self.p2GotCard;
    }
}
-(void)putCardInDiscard:(Card *)card player:(BOOL)p1 {
    if ([self canPutCardInDiscard:p1]) {
        [self.discardDeck addCard:card];
        [self.delegate updateDiscard];
        [self reset];
    }
}

-(void)reset {
    self.p1GotCard = NO;
    self.p2GotCard = NO;
    
    self.player1Turn = !self.player1Turn;
    [self.delegate updateTurn];
}

-(BOOL)didWin:(NSArray<Card*>*)hand {
    return [self canWin:hand withGroups:[NSMutableArray array]];
}

-(BOOL)canWin:(NSArray<Card*>*)cards withGroups:(NSArray*)groups {
    if ([cards count] == 0) {
        for (NSArray* group in groups) { //Check if all groups have at least 3 cards
            if ([group count] < 3) {
                return NO;
            }
        }
        return YES;
    }
    
    Card* card = cards[0];
    NSArray* newCards = [cards subarrayWithRange:NSMakeRange(1, [cards count] - 1)]; //remove first card from cards and make a copy of the array
    
    //checks whether card belongs in an existing group
    for (int i = 0; i < [groups count]; i++) {
        if ([self canAddCard:card toGroup:groups[i]]) {
            NSMutableArray* newGroups = [groups mutableCopy]; //don't want to change the original array so it can be used each time
            [newGroups[i] addObject:card]; //add to correct group
            if ([self canWin:newCards withGroups:newGroups]) { //recursive call, check if the situation is winnable
                return YES;
            }
        }
    }
    
    //if we didn't already win, checks whether card belongs in a new group
    NSMutableArray* newGroups = [groups mutableCopy];
    [newGroups addObject:[NSMutableArray arrayWithObject:card]]; // make new group and add it
    if ([self canWin:newCards withGroups:newGroups]) { //recursive call, check if the situation is winnable
        return YES;
    }
    
    return NO; //if we haven't won by now, then we can't win with this option
}

-(BOOL)canAddCard:(Card*)card toGroup:(NSArray<Card*>*)group {
    if ([group count] == 0) {
        return NO;
    }
    
    if (card.rank == group[0].rank) {
        return YES;
    } else if (card.suit == group[0].suit) {
        for (Card* groupCard in group) {
            NSInteger groupCardNum = [Card rankNumber:groupCard.rank];
            NSInteger cardNum = [Card rankNumber:card.rank];
            if (cardNum + 1 == groupCardNum || cardNum - 1 == groupCardNum) {
                return YES;
            }
        }
        return NO;
    } else {
        return NO;
    }
}

@end
