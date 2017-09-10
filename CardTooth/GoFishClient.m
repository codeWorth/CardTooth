//
//  GoFishClient.m
//  CardTooth
//
//  Created by Andrew Cummings on 8/6/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "GoFishClient.h"

@implementation GoFishClient

-(instancetype)initWithMeUUID:(NSString *)me {
    if (self = [super init]) {
        self.meUUID = me;
        self.currentPlayer = 0;
    }
    return self;
}

-(void)beginGameWithCards:(NSArray<Card*>*)cards playerOrder:(NSArray<NSString *> *)playerUUIDs me:(NSString *)meUUID andHand:(NSArray *)hand {
    self.cards = [[CardDeck alloc] init];
    [self.cards emptyDeck];
    [self.cards addCards:cards];
    
    self.playerUUIDs = playerUUIDs;
    
    self.meUUID = meUUID;
    self.hand = [hand mutableCopy];
    
    self.handSize = 7;
    if ([self.playerUUIDs count] > 3) {
        self.handSize = 5;
    }
    
    [self nextTurn];
}

@end
