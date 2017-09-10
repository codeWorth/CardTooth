//
//  DataManager.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/28/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "GinRummy.h"

@protocol DataManagerGameDelegate <NSObject>

-(void)weWon;
-(void)weLost;

@end

@interface DataManager : NSObject

-(instancetype)initAsHost:(BOOL)amHost withGame:(GinRummy*)game;
@property (nonatomic) BOOL amHost;
@property (nonatomic, weak) id<DataManagerGameDelegate> delegate;

-(void)processRecievedMessage:(NSString*)msg;

-(void)sendStart:(BOOL)player1Starts;
-(void)sendHand:(NSArray<Card*>*)cards;
-(void)sendDrawPile:(NSArray<Card*>*)cards;
-(void)sendTookFromDrawPile;
-(void)sendTookFromDiscardPile;
-(void)sendPlaceCardOnDiscardPile:(Card*)card;
-(void)sendVictory;
-(void)sendConcede;
-(void)sendGame:(NSString*)game;

@end
