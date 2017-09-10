//
//  CardDeck.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/7/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface CardDeck : NSObject

-(Card*)topCard;
-(Card*)popTopCard;
-(NSArray<Card*>*)top:(NSInteger)cards;
-(NSArray<Card*>*)cards;

-(void)resetDeck;

-(void)emptyDeck;
-(void)addCard:(Card*)card;
-(void)addCards:(NSArray<Card*>*)cards;

-(NSInteger)numberOfRank:(NSString*)rank;

@end
