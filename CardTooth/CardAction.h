//
//  CardAction.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/18/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "Pile.h"

@protocol CardCondition <NSObject>

-(BOOL)canPlaceCard:(Card*)moveCard onCard:(Card*)destCard;

@end

@interface CardAction : NSObject

@property (nonatomic, weak) Pile* sourcePile;
@property (nonatomic, strong) NSMutableArray<Pile*>* destinationPiles;
@property (nonatomic, strong) id<CardCondition> condition;

@end
