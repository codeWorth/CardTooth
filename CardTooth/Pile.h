//
//  PileConfig.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/17/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardDeck.h"
#import "Card.h"

@protocol Resetable <NSObject>

-(void)resetWithCards:(NSArray<Card*>*)cards;
-(NSInteger)startingSize;

@end

@interface Pile : NSObject <Resetable>

-(instancetype)initFaceUp:(BOOL)faceUp;

-(instancetype)initWithSize:(NSInteger)size faceUp:(BOOL)faceUp;

@property (nonatomic) BOOL faceUp;

-(CardDeck*)deck;

-(NSInteger)startingSize;

-(void)addCard:(Card*)card;
-(void)moveTopCardToPile:(Pile*)pile;

-(void)resetWithCards:(NSArray<Card*>*)cards;

@end
