//
//  GoFishDataManager.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/31/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoFish.h"

@protocol GoFishDataManagerDelegate <NSObject>

-(void)hand:(NSArray<Card*>*)hand;
-(void)gotCards:(NSArray<Card*>*)cards;
-(void)playerUUIDs:(NSArray<NSString*>*)uuids andNames:(NSArray<NSString*>*)names;

-(void)startGame;
-(void)updateTurn;

-(void)player:(NSString*)askerUUID wantsRank:(NSInteger)rank;

-(void)gotBooks:(NSArray<Card*>*)books forPlayer:(NSString*)playerUUID;

@end

@interface GoFishDataManager : NSObject <GoFishDelegate>

-(instancetype)initAsHost:(BOOL)amHost withGame:(GoFish*)game;
@property (nonatomic) BOOL amHost;
@property (nonatomic, weak) id<GoFishDataManagerDelegate> delegate;

-(void)playerBooks:(NSString*)playerUUID;

-(void)processRecievedMessage:(NSString*)msg;

-(void)sendBeginGame;
-(void)sendVictory;
-(void)sendConcede;
-(void)sendGame;
-(void)sendCard:(Card*)card;
-(void)sendPlayerNames:(NSArray<NSString*>*)names;
-(void)sentLastCard;
-(void)sendFished;

@end
