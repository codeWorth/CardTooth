//
//  DefaultCardHandView.m
//  CardTooth
//
//  Created by Andrew Cummings on 8/4/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "DefaultCardHandView.h"

@interface DefaultCardHandView ()

@property (nonatomic, strong) NSMutableArray<CardView*>* cards;

@property (nonatomic) CGFloat cardWidth;
@property (nonatomic) CGFloat cardHeight;
@property (nonatomic) CGFloat cardSpace;
@property (nonatomic) CGRect _parentFrame;

@property (nonatomic) CGFloat offset;
@property (nonatomic) CGFloat yBuffer;
@property (nonatomic) CGFloat xBuffer;

@end

#define MIN_SPACE -0.5
#define MAX_SPACE 0.08
#define ASPECT_RATIO 0.7
#define OUTSIDE_Y_SPACE 0.3
#define OUTSIDE_X_SPACE 0.1;

@implementation DefaultCardHandView

-(instancetype)initForFrame:(CGRect)frame {
    if (self = [super init]) {
        self.cards = [NSMutableArray array];
        self.parentFrame = frame;
    }
    return self;
}

-(instancetype)init {
    if (self = [super init]) {
        self.cards = [NSMutableArray array];
    }
    return self;
}

-(void)setParentFrame:(CGRect)frame {
    self._parentFrame = frame;
    self.cardHeight = frame.size.height;
    self.cardWidth = self.cardHeight * ASPECT_RATIO;
    self.yBuffer = self._parentFrame.size.height * OUTSIDE_Y_SPACE;
    self.xBuffer = self._parentFrame.size.width * OUTSIDE_X_SPACE;
}

-(CardView*)replaceCardView:(CardView *)cardView forIndex:(NSUInteger)index {
    CardView* old = self.cards[index];
    [self.cards replaceObjectAtIndex:index withObject:cardView];
    
    cardView.tag = index;
    [cardView setPosition:old.frame.origin];
    
    return old;
}

-(BOOL)cardNearRangeForPosition:(CGPoint)point {
    if (point.x < self._parentFrame.origin.x - self.xBuffer || point.x > self._parentFrame.origin.x + self._parentFrame.size.width + self.xBuffer) {
        return NO;
    }
    
    if (point.y < self._parentFrame.origin.y - self.yBuffer || point.y > self._parentFrame.origin.y + self._parentFrame.size.height + self.yBuffer) {
        return NO;
    }
    
    return YES;
}

-(BOOL)cardInRangeForPosition:(CGPoint)point {
    if (point.x < self._parentFrame.origin.x || point.x > self._parentFrame.origin.x + self._parentFrame.size.width) {
        return NO;
    }
    
    if (point.y < self._parentFrame.origin.y || point.y > self._parentFrame.origin.y + self._parentFrame.size.height) {
        return NO;
    }
    
    return YES;
}

-(BOOL)card:(Card *)card atSlot:(NSUInteger)index needsMove:(CGFloat)xPos {
    return index != [self indexForCard:card andPosition:xPos];
}

-(NSUInteger)indexForCard:(Card *)card andPosition:(CGFloat)xPos {
    if (xPos < 0) {
        return 0;
    }
    
    if ([self.cards count] == 0) {
        return 0;
    }
    
    CGFloat adjustedPos = xPos + (self.cardSpace + self.cardWidth)/2 - [self.cards objectAtIndex:0].frame.origin.x;
    NSInteger slot = floor( adjustedPos / (self.cardSpace + self.cardWidth) );
    
    if (slot < 0) {
        return 0;
    } else if (slot > [self.cards count]) {
        return [self.cards count];
    } else {
        return slot;
    }
}

-(CardView*)cardViewForIndex:(NSUInteger)index {
    return self.cards[index];
}

-(CGFloat)positionForIndex:(NSUInteger)index {
    NSInteger xPos = index * (self.cardSpace + self.cardWidth) + self.offset;
    return xPos;
}

-(void)removeCardView:(CardView *)view {
    [self.cards removeObject:view];
    [self calculateSpacing];
}

-(NSUInteger)cardCount {
    return [self.cards count];
}

-(BOOL)addCardView:(CardView *)cardView forPosition:(CGFloat)xPos {
    cardView.frame = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y, self.cardWidth, self.cardHeight);
    
    NSUInteger index = [self indexForCard:cardView.card andPosition:xPos];
    [self.cards insertObject:cardView atIndex:index];
    cardView.tag = index;
    return [self calculateSpacing];
}

-(void)updateTags {
    NSInteger index = 0;
    for (CardView* view in self.cards) {
        view.tag = index;
        index++;
    }
}

-(BOOL)calculateSpacing {
    if ([self.cards count] == 0) {
        return NO;
    }
    
    [self updateTags];
    
    CGFloat maxSpace = self.cardWidth * MAX_SPACE;
    CGFloat minSpace = self.cardWidth * MIN_SPACE;
    
    NSInteger spacers = [self.cards count] - 1;
    CGFloat remainingSpace = self._parentFrame.size.width - self.cardWidth * [self.cards count];
    self.cardSpace = remainingSpace/spacers;
    
    if (self.cardSpace < minSpace) {
        self.cardSpace = minSpace;
        return YES;
    } else {
        self.offset = 0;
        
        if (self.cardSpace > maxSpace) {
            self.cardSpace = maxSpace;
            
            CGFloat totalCardsWidth = (self.cardSpace + self.cardWidth) * [self.cards count];
            CGFloat midX = self._parentFrame.size.width/2;
            self.offset = midX - totalCardsWidth/2;
        }
    }
    
    return NO;
}

-(NSArray<Card *> *)getCards {
    NSMutableArray* theCards = [NSMutableArray array];
    for (CardView* card in self.cards) {
        [theCards addObject:card.card];
    }
    return theCards;
}

@end
