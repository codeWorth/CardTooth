//
//  DataManager.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/28/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "DataManager.h"
#import "CBHostManager.h"
#import "CBClientManager.h"
#import "GinRummyClient.h"

@interface DataManager ()

@property (nonatomic, strong) NSArray<Card*>* drawCards;
@property (nonatomic, strong) NSArray<Card*>* thisPlayerHand;
@property (nonatomic) BOOL player1Turn;

@property (nonatomic, weak) GinRummy* game;

@end

@implementation DataManager

-(instancetype)initAsHost:(BOOL)amHost withGame:(GinRummy *)game {
    if (self = [super init]) {
        self.amHost = amHost;
        self.game = game;
    }
    return self;
}

-(void)processRecievedMessage:(NSString *)msg {
    NSArray<NSString*>* halfs = [msg componentsSeparatedByString:@":"];
    NSString* key = halfs[0];
    
    if ([key isEqualToString:@"Start"]) {
        NSString* data = halfs[1];
        if ([data isEqualToString:@"P1"]) {
            self.player1Turn = YES;
        } else if ([data isEqualToString:@"P2"]) {
            self.player1Turn = NO;
        }
        if (!self.amHost) {
            [(GinRummyClient*)self.game beginGame:self.drawCards p1Hand:self.thisPlayerHand andP1:self.player1Turn];
        }
    } else if ([key isEqualToString:@"Hand"]) {
        NSString* data = halfs[1];
        self.thisPlayerHand = [self decryptListOfCards:data];
    } else if ([key isEqualToString:@"Pile"]) {
        NSString* data = halfs[1];
        self.drawCards = [self decryptListOfCards:data];
    } else if ([key isEqualToString:@"TookFromDraw"]) {
        [self.game getCardFromCards:!self.amHost];
    } else if ([key isEqualToString:@"TookFromDiscard"]) {
        [self.game getCardFromDiscards:!self.amHost];
    } else if ([key isEqualToString:@"Discard"]) {
        NSString* data = halfs[1];
        Card* discarded = [self decryptListOfCards:data][0];
        [self.game putCardInDiscard:discarded player:!self.amHost];
    } else if ([key isEqualToString:@"Concede"]) {
        [self.delegate weWon];
    } else if ([key isEqualToString:@"Victory"]) {
        [self.delegate weLost];
    } else {
        NSLog(@"yo wtf");
    }
}

-(void)sendGame:(NSString *)game {
    [self sendMessage:game];
}

-(void)sendStart:(BOOL)player1Starts {
    if (player1Starts) {
        [self sendMessage:@"Start:P1"];
    } else {
        [self sendMessage:@"Start:P2"];
    }
}

-(void)sendHand:(NSArray<Card *> *)cards {
    [self sendMessage:[@"Hand:" stringByAppendingString:[self listOfCards:cards]]];
}

-(void)sendDrawPile:(NSArray<Card *> *)cards {
    [self sendMessage:[@"Pile:" stringByAppendingString:[self listOfCards:cards]]];
}

-(void)sendTookFromDrawPile {
    [self sendMessage:@"TookFromDraw"];
}

-(void)sendTookFromDiscardPile {
    [self sendMessage:@"TookFromDiscard"];
}

-(void)sendPlaceCardOnDiscardPile:(Card *)card {
    long suit = [Card suitNumber:card.suit];
    long rank = [Card rankNumber:card.rank];
    NSString* msg = [NSString stringWithFormat:@"Discard:%li %li", suit, rank];
    [self sendMessage:msg];
}

-(void)sendConcede {
    [self sendMessage:@"Concede"];
}

-(void)sendVictory {
    [self sendMessage:@"Victory"];
}

-(NSString*)listOfCards:(NSArray<Card *> *)cards {
    NSMutableString* list = [NSMutableString string];
    for (int i = 0; i < [cards count]; i++) {
        Card* card = cards[i];
        long suit = [Card suitNumber:card.suit];
        long rank = [Card rankNumber:card.rank];
        if (i == 0) {
            [list appendString:[NSString stringWithFormat:@"%li %li", suit, rank]];
        } else {
            [list appendString:[NSString stringWithFormat:@",%li %li", suit, rank]];
        }
    }
    return list;
}

-(NSArray<Card*>*)decryptListOfCards:(NSString*)list {
    NSMutableArray<Card*>* cards = [NSMutableArray array];
    
    NSArray<NSString*>* cardStrings = [list componentsSeparatedByString:@","];
    for (NSString* cardString in cardStrings) {
        NSArray<NSString*>* suitAndRank = [cardString componentsSeparatedByString:@" "];
        NSInteger suit = [suitAndRank[0] integerValue];
        NSString* suitString = [Card suits][suit];
        
        NSInteger rank = [suitAndRank[1] integerValue];
        NSString* rankString = [Card ranks][rank];
        
        Card* newCard = [[Card alloc] initWithSuit:suitString andRank:rankString];
        [cards addObject:newCard];
    }
    return cards;
}

-(void)sendMessage:(NSString*)msg {
    if (self.amHost) {
        [[CBHostManager instance] sendMessage:msg];
    } else {
        [[CBClientManager instance] sendMessage:msg];
    }
}

@end
