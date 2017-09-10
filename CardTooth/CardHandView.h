//
//  CardHandView.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/27/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import "CardView.h"

@class CardHandView;

@protocol CardHandViewDelegate <NSObject>

-(BOOL)cardView:(CardHandView*)view outsideReleased:(CardView*)cardView;

@end

@protocol CardHandViewDataSource <NSObject>

-(BOOL)addCardView:(CardView*)cardView forPosition:(CGFloat)xPos; //returns YES if overflow size-wise
-(void)removeCardView:(CardView*)view;
-(CardView*)replaceCardView:(CardView*)cardView forIndex:(NSUInteger)index; //returns popped card

-(CardView*)cardViewForIndex:(NSUInteger)index;
-(CGFloat)positionForIndex:(NSUInteger)index;
-(NSUInteger)cardCount;

-(BOOL)cardNearRangeForPosition:(CGPoint)point;
-(BOOL)cardInRangeForPosition:(CGPoint)point;
-(BOOL)card:(Card*)card atSlot:(NSUInteger)index needsMove:(CGFloat)xPos;

-(void)setParentFrame:(CGRect)frame;

@end

@interface CardHandView : UIView <CardViewDelegate>

@property (nonatomic, weak) id<CardHandViewDelegate> delegate;
-(id<CardHandViewDataSource>)activeDataSource;
-(void)setDataSourceInitialObject:(id<CardHandViewDataSource>)dataSource;

-(void)addCard:(Card *)card;
-(void)addCardView:(CardView*)cardView forPosition:(NSInteger)xPos;
-(void)pickUpCard:(CardView*)card referencePos:(CGPoint)pos;

@end
