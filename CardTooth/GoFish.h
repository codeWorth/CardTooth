//
//  GoFish.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/30/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "CardDeck.h"

@protocol GoFishDelegate <NSObject>

-(void)playerOrder:(NSArray*)playerUUIDs;
-(void)playerHand:(NSArray<Card*>*)cards player:(NSString*)playerUUID;
-(void)drawDeck:(CardDeck*)deck;

-(void)player:(NSString*)askerUUID wantsCard:(Card*)card fromPlayer:(NSString*)recieverUUID;

-(void)start;
-(void)updateTurn;

@end

@interface GoFish : NSObject

-(instancetype)initWithPlayers:(NSArray*)playerUUIDs; //pass my player in as last player in list
-(void)beginGame;

-(BOOL)canFish;
-(Card*)fish;

-(BOOL)canAskForCard:(Card*)card fromPlayer:(NSString*)recieverUUID;
-(void)askForCard:(Card*)card fromPlayer:(NSString*)recieverUUID;
-(void)recievedCards:(NSArray<Card*>*)cards;

-(BOOL)hasAnyOfRank:(NSString*)rank;

-(NSArray<Card*>*)myBooks;

-(void)nextTurn;

@property (nonatomic, strong) CardDeck* cards;
@property (nonatomic, strong) NSMutableArray<Card*>* hand;
@property (nonatomic) NSInteger handSize;

@property (nonatomic, strong) NSArray* playerUUIDs;
@property (nonatomic) NSInteger currentPlayer;
@property (nonatomic, strong) NSString* meUUID;
@property (nonatomic, strong) Card* lastAskedFor;

@property (nonatomic) BOOL needsFish;
@property (nonatomic) BOOL canAsk;

@property (nonatomic) NSInteger recievedCards;

@property (nonatomic, weak) id<GoFishDelegate> delegate;

@end
