//
//  GoFish.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/30/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "GoFish.h"

@implementation GoFish

-(instancetype)initWithPlayers:(NSArray *)playerUUIDs {
    if (self = [super init]) {
        self.playerUUIDs = playerUUIDs;
        self.meUUID = [self.playerUUIDs lastObject];
        self.currentPlayer = 0;
        self.cards = [[CardDeck alloc] init];
        
        self.handSize = 7;
        if ([self.playerUUIDs count] > 3) {
            self.handSize = 5;
        }
        
        NSMutableArray* temp = [NSMutableArray arrayWithArray:self.playerUUIDs];
        NSMutableArray* newPlayers = [NSMutableArray array];
        
        NSInteger items = [self.playerUUIDs count];
        NSInteger i = 0;
        while (i < items) {
            NSInteger rand = arc4random_uniform((int)[temp count]);
            [newPlayers addObject:temp[rand]];
            [temp removeObjectAtIndex:rand];
            i++;
        }
        self.playerUUIDs = newPlayers;
    }
    return self;
}

-(void)beginGame {
    [self.delegate playerOrder:self.playerUUIDs];
    
    for (NSString* player in self.playerUUIDs) {
        NSMutableArray* hand = [NSMutableArray arrayWithArray:[self.cards top:self.handSize]];
        if ([player isEqualToString:self.meUUID]) {
            self.hand = hand;
        }
        [self.delegate playerHand:hand player:player];
    }
    
    [self.delegate drawDeck:self.cards];
    
    [self.delegate start];
    [self nextTurn];
}

-(BOOL)canAskForCard:(Card *)card fromPlayer:(NSString *)recieverUUID {
    if (!self.canAsk) {
        return NO;
    }
    
    return [self.hand containsObject:card];
}

-(void)askForCard:(Card *)card fromPlayer:(NSString *)recieverUUID {
    if ([self canAskForCard:card fromPlayer:recieverUUID]) {
        self.canAsk = NO;
        [self.delegate player:self.meUUID wantsCard:card fromPlayer:recieverUUID];
    }
}

-(void)recievedCards:(NSArray<Card *> *)cards {
    if ([cards count] == 1) {
        self.needsFish = YES;
    } else {
        [self.hand addObjectsFromArray:cards];
        self.canAsk = YES;
    }
}

-(BOOL)hasAnyOfRank:(NSString *)rank {
    for (Card* card in self.hand) {
        if ([card.rank isEqualToString:rank]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)canFish {
    if ([self.playerUUIDs[self.currentPlayer] isEqualToString:self.meUUID]) {
        return self.needsFish;
    } else {
        return NO;
    }
}
-(Card*)fish {
    if ([self canFish]) {
        Card* newCard = [self.cards popTopCard];
        [self.hand addObject:newCard];
        
        if ([newCard.rank isEqualToString:self.lastAskedFor.rank]) {
            self.canAsk = YES;
            self.needsFish = NO;
        } else {
            [self nextTurn];
        }
        
        return newCard;
    }
    return nil;
}

-(void)nextTurn {
    self.currentPlayer++;
    if (self.currentPlayer == [self.playerUUIDs count]) {
        self.currentPlayer = 0;
    }
    
    if ([self.playerUUIDs[self.currentPlayer] isEqualToString:self.meUUID]) {
        self.needsFish = NO;
        self.canAsk = YES;
    }
    
    [self.delegate updateTurn];
}

-(NSInteger)playerIndex:(NSString*)player {
    return [self.playerUUIDs indexOfObject:player];
}

-(NSArray<Card *> *)myBooks {
    NSMutableArray<NSMutableArray*>* books = [NSMutableArray array];
    for (Card* card in self.hand) {
        NSInteger index = [self rankIndex:card.rank in:books];
        if (index == -1) {
            [books addObject:[NSMutableArray arrayWithObject:card]];
        } else {
            [books[index] addObject:card];
        }
    }
    
    NSMutableArray* bookCards = [NSMutableArray array];
    for (NSArray<Card*>* book in books) {
        if ([book count] == 4) {
            [bookCards addObjectsFromArray:book];
        }
    }
    
    return bookCards;
}
-(NSInteger)rankIndex:(NSString*)rank in:(NSArray*)books {
    for (int i = 0; i < [books count]; i++) {
        NSArray<Card*>* book = books[i];
        if ([book[0].rank isEqualToString:rank]) {
            return i;
        }
    }
    return -1;
}

@end
