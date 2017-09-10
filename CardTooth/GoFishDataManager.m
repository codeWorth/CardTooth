//
//  GoFishDataManager.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/31/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "GoFishDataManager.h"
#import "CBHostManager.h"
#import "CBClientManager.h"
#import "GoFishClient.h"

@interface GoFishDataManager ()

@property (nonatomic, strong) GoFish* game;
@property (nonatomic, strong) NSString* meUUID;
@property (nonatomic, strong) NSString* wantingPlayer;

@property (nonatomic, strong) NSMutableArray<Card*>* recievedCards;

@property (nonatomic, strong) NSArray* storedHand;
@property (nonatomic, strong) NSArray* storedPlayerOrder;
@property (nonatomic, strong) NSArray* storedPlayerNames;
@property (nonatomic, strong) NSArray* storedDeck;

@end

@implementation GoFishDataManager

-(instancetype)initAsHost:(BOOL)amHost withGame:(GoFish *)game {
    if (self = [super init]) {
        self.amHost = amHost;
        self.game = game;
        self.game.delegate = self;
        self.meUUID = game.meUUID;
        self.recievedCards = [NSMutableArray array];
    }
    return self;
}

-(void)processRecievedMessage:(NSString *)msg {
    NSArray<NSString*>* parts = [msg componentsSeparatedByString:@":"];
    
    if ([parts[0] isEqualToString:@"To"]) {
        
        NSString* dest = parts[1];
        NSRange range  = NSMakeRange(2, [parts count] - 2);
        NSString* subMsg = [[parts subarrayWithRange:range] componentsJoinedByString:@":"];
        
        if ([dest isEqualToString:self.game.meUUID]) {
            [self processRecievedMessage:subMsg];
        }
        
        [self sendMessage:subMsg toPlayer:dest];
        
    } else if ([parts[0] isEqualToString:@"Wanted"]) {
        
        NSString* askerUUID = parts[1];
        NSInteger cardRank = [parts[2] integerValue];
        self.wantingPlayer = askerUUID;
        [self.delegate player:askerUUID wantsRank:cardRank];
        
    } else if ([parts[0] isEqualToString:@"Hand"]) {
        
        self.storedHand = [self decryptListOfCards:parts[1]];
        
    } else if ([parts[0] isEqualToString:@"Gave"]) {
        
        NSArray<NSString*>* suitAndRank = [parts[1] componentsSeparatedByString:@" "];
        NSInteger suit = [suitAndRank[0] integerValue];
        NSString* suitString = [Card suits][suit];
        
        NSInteger rank = [suitAndRank[1] integerValue];
        NSString* rankString = [Card ranks][rank];
        
        Card* newCard = [[Card alloc] initWithSuit:suitString andRank:rankString];
        [self.recievedCards addObject:newCard];
        
    } else if ([parts[0] isEqualToString:@"GaveDone"]) {
        
        [self.delegate gotCards:[self.recievedCards copy]];
        [self.recievedCards removeAllObjects];
        
    } else if ([parts[0] isEqualToString:@"Deck"]) {
        
        self.storedDeck = [self decryptListOfCards:parts[1]];
        
    } else if ([parts[0] isEqualToString:@"Players"]) {
        
        self.storedPlayerOrder = [self decryptListOfPlayers:parts[1]];
        
    } else if ([parts[0] isEqualToString:@"Start"]) {
        
        if (!self.amHost) {
            GoFishClient* gameClient = (GoFishClient*)self.game;
            [gameClient beginGameWithCards:self.storedDeck playerOrder:self.storedPlayerOrder me:self.meUUID andHand:self.storedHand];
            [self.delegate hand:gameClient.hand];
            [self.delegate playerUUIDs:self.storedPlayerOrder andNames:self.storedPlayerNames];
            [self.delegate startGame];
        }
        
    } else if ([parts[0] isEqualToString:@"Fished"]) {
        
        [self.game nextTurn];
        
    } else if ([parts[0] isEqualToString:@"Names"]) {
        
        self.storedPlayerNames = [self decryptListOfPlayers:parts[1]];
        
    }
}

-(void)drawDeck:(CardDeck *)deck {
    NSString* msg = [NSString stringWithFormat:@"Deck:%@", [self listOfCards:deck.cards]];
    [self sendMessage:msg toPlayer:nil];
}

-(void)player:(NSString *)askerUUID wantsCard:(Card *)card fromPlayer:(NSString *)recieverUUID {
    NSString* msg = [NSString stringWithFormat:@"Wanted:%@:%li", askerUUID, (long)[Card rankNumber:card.rank]];
    [self sendMessage:msg toPlayer:recieverUUID];
}

-(void)playerHand:(NSArray<Card *> *)cards player:(NSString *)playerUUID {
    if ([playerUUID isEqualToString:self.meUUID]) {
        [self.delegate hand:cards];
    } else {
        NSString* cardsList = [self listOfCards:cards];
        [self sendMessage:[@"Hand:" stringByAppendingString:cardsList] toPlayer:playerUUID];
    }
}

-(void)playerOrder:(NSArray *)playerUUIDs {
    NSString* playersList = [self listOfPlayers:playerUUIDs];
    [self sendMessage:[@"Players:" stringByAppendingString:playersList] toPlayer:nil];
}

-(void)sendPlayerNames:(NSArray<NSString *> *)names {
    NSString* namesList = [self listOfPlayers:names];
    [self sendMessage:[NSString stringWithFormat:@"Names:%@", namesList] toPlayer:nil];
}

- (void)sendConcede {
    [self sendMessage:@"Concede" toPlayer:nil];
}

- (void)sendVictory {
    [self sendMessage:@"Won" toPlayer:nil];
}

-(void)sendBeginGame {
    [self sendMessage:@"Start" toPlayer:nil];
}

-(void)sendGame {
    [self sendMessage:@"Go Fish" toPlayer:nil];
}

-(void)sendCard:(Card *)card {
    long suit = [Card suitNumber:card.suit];
    long rank = [Card rankNumber:card.rank];
    NSString* msg = [NSString stringWithFormat:@"Gave:%li %li", suit, rank];
    
    [self sendMessage:msg toPlayer:self.wantingPlayer];
}

-(void)sentLastCard {
    [self sendMessage:@"GaveDone" toPlayer:self.wantingPlayer];
}

-(void)sendFished {
    [self sendMessage:[NSString stringWithFormat:@"Fished:%@", self.meUUID] toPlayer:nil];
}

-(void)sendMessage:(NSString*)message toPlayer:(NSString*)playerUUID {
    if (playerUUID == nil) {
        if (self.amHost) {
            [[CBHostManager instance] sendMessageToAllPeriperals:message];
        } else {
            [[CBClientManager instance] sendMessage:message];
        }
    } else {
        if (self.amHost) {
            [[CBHostManager instance] sendMessage:message toPeripheral:playerUUID];
        } else {
            NSString* fullMessage = [NSString stringWithFormat:@"To:%@:%@", playerUUID, message];
            [[CBClientManager instance] sendMessage:fullMessage];
        }
    }
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

-(void)playerBooks:(NSString *)playerUUID {
    if ([playerUUID isEqualToString:self.meUUID]) {
        [self.delegate gotBooks:[self.game myBooks] forPlayer:self.meUUID];
    } else {
        [self sendMessage:@"Books" toPlayer:playerUUID];
    }
}

-(void)updateTurn {
    [self.delegate updateTurn];
}

-(void)start {
    [self.delegate startGame];
}

-(NSString*)listOfPlayers:(NSArray<NSString*>*)playerUUIDs {
    return [playerUUIDs componentsJoinedByString:@","];
}

-(NSArray*)decryptListOfPlayers:(NSString*)playersString {
    return [playersString componentsSeparatedByString:@","];
}

@end
