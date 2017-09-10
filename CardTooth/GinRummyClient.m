//
//  GinRummyClient.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/28/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "GinRummyClient.h"
#import "CardDeck.h"

@implementation GinRummyClient

-(instancetype)initWithDelegate:(id<GinRummyDelegate>)delegate {
    if (self = [super init]) {
        self.cardDeck = [[CardDeck alloc] init];
        [self.cardDeck emptyDeck];
        self.discardDeck = [[CardDeck alloc] init];
        [self.discardDeck emptyDeck];
        
        self.delegate = delegate;
    }
    return self;
}

-(void)beginGame:(NSArray<Card *> *)cards p1Hand:(NSArray<Card *> *)p1Hand andP1:(BOOL)p1 {
    [self.cardDeck addCards:cards];
    [self.delegate player1Hand:p1Hand];
    self.player1Turn = p1;
    [self.delegate updateTurn];
    
    [self.discardDeck addCard:[self.cardDeck popTopCard]];
    [self.delegate updateDiscard];
}

@end
