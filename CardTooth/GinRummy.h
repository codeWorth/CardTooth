//
//  GinRummy.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/27/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "CardDeck.h"

@protocol GinRummyDelegate <NSObject>

-(void)player1Hand:(NSArray<Card*>*)cards;
-(void)player2Hand:(NSArray<Card*>*)cards;
-(void)updateDiscard;
-(void)updateTurn;

@end

@interface GinRummy : NSObject

-(instancetype)initWithDelegate:(id<GinRummyDelegate>)delegate;
-(void)beginGame;

-(Card*)getCardFromCards:(BOOL)p1;
-(BOOL)canGetCardFromCards:(BOOL)p1;

-(Card*)getCardFromDiscards:(BOOL)p1;
-(BOOL)canGetCardFromDiscard:(BOOL)p1;
-(Card*)topDiscard;

-(BOOL)canTakeCardFromHand:(BOOL)p1;
-(BOOL)canPutCardInDiscard:(BOOL)p1;
-(void)putCardInDiscard:(Card*)card player:(BOOL)p1;

-(BOOL)didWin:(NSArray<Card*>*)hand;

@property (nonatomic, strong) CardDeck* cardDeck;
@property (nonatomic, strong) CardDeck* discardDeck;
@property (nonatomic) BOOL player1Turn;

@property (nonatomic) BOOL p1GotCard;
@property (nonatomic) BOOL p2GotCard;

@property (nonatomic, weak) id<GinRummyDelegate> delegate;

@end
