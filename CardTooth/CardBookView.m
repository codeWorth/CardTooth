//
//  CardBookView.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/30/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "CardBookView.h"

@interface CardBookView ()

@property (nonatomic, strong) NSMutableArray<NSMutableArray<CardView*>*>* books;
@property (nonatomic, strong) NSMutableArray<CardView*>* cards;

@property (nonatomic) CGFloat cardWidth;
@property (nonatomic) CGFloat cardHeight;
@property (nonatomic) CGFloat sameCardSpace;
@property (nonatomic) CGRect _parentFrame;

@property (nonatomic) CGFloat bookSpacerSize;
@property (nonatomic) CGFloat offset;
@property (nonatomic) CGFloat yBuffer;
@property (nonatomic) CGFloat xBuffer;

@end

#define SAME_CARD_SPACE -0.9
#define BOOK_MIN_SPACE -0.2
#define BOOK_MAX_SPACE 0.5
#define ASPECT_RATIO 0.7
#define OUTSIDE_Y_SPACE 0.3
#define OUTSIDE_X_SPACE 0.1;

@implementation CardBookView

-(instancetype)initForFrame:(CGRect)frame {
    if (self = [super init]) {
        self.books = [NSMutableArray array];
        self.cards = [NSMutableArray array];
        
        self.parentFrame = frame;
    }
    return self;
}

-(instancetype)init {
    if (self = [super init]) {
        self.books = [NSMutableArray array];
        self.cards = [NSMutableArray array];        
    }
    return self;
}

-(void)setParentFrame:(CGRect)frame {
    self._parentFrame = frame;
    self.cardHeight = frame.size.height;
    self.cardWidth = self.cardHeight * ASPECT_RATIO;
    self.sameCardSpace = self.cardWidth * SAME_CARD_SPACE;
    self.yBuffer = self._parentFrame.size.height * OUTSIDE_Y_SPACE;
    self.xBuffer = self._parentFrame.size.width * OUTSIDE_X_SPACE;
}

-(CardView*)replaceCardView:(CardView *)cardView forIndex:(NSUInteger)index {
    CardView* old = self.cards[index];
    [self.cards replaceObjectAtIndex:index withObject:cardView];
    
    CGPoint path = [self flatIndexToPath:index];
    [self.books[(int)path.x] replaceObjectAtIndex:path.y withObject:cardView];
    
    cardView.tag = index;
    cardView.frame = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y, self.cardWidth, self.cardHeight);
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
    return [self pathToFlatIndex:[self indexPathForCard:card andPosition:xPos]];
}

-(CGPoint)indexPathForCard:(Card *)card andPosition:(CGFloat)xPos {
    CGPoint cardPos = [self addIndexForCard:card];
    if (cardPos.x == -1) {
        NSUInteger bookIndex = [self bookIndexForPosition:xPos];
        
        if (bookIndex == [self.books count]) {
            return CGPointMake([self.books count], 0);
        } else {
            return CGPointMake(bookIndex, 0);
        }
    } else {
        cardPos = CGPointMake(cardPos.x, cardPos.y - 1);
        return cardPos;
    }
}

-(CardView*)cardViewForIndex:(NSUInteger)index {
    return self.cards[index];
}

-(CGFloat)positionForIndex:(NSUInteger)index {
    CGFloat xPos = self.offset;
    
    NSInteger cardIndex = 0;
    
    for (NSArray<Card*>* book in self.books) {
        for (Card* card in book) {
            if (cardIndex == index) {
                return xPos;
            }
            
            xPos += self.cardWidth;
            xPos += self.sameCardSpace;
            
            cardIndex++;
            
        }
        xPos -= self.cardWidth * SAME_CARD_SPACE;
        xPos += self.bookSpacerSize;
    }
    
    return xPos;
}

-(void)removeCardView:(CardView *)view {
    [self.cards removeObject:view];
    
    for (NSMutableArray<CardView*>* book in self.books) {
        for (CardView* card in book) {
            if (card == view) {
                [book removeObject:view];
                if ([book count] == 0) {
                    [self.books removeObject:book];
                    [self calculateSpacing];
                    return;
                }
            }
        }
    }
    
    
    [self calculateSpacing];
}

-(NSUInteger)cardCount {
    return [self.cards count];
}

-(BOOL)addCardView:(CardView *)cardView forPosition:(CGFloat)xPos {
    cardView.frame = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y, self.cardWidth, self.cardHeight);
    
    CGPoint path = [self addIndexForCard:cardView.card];
    if (path.x == -1) {
        NSUInteger bookIndex;
        NSUInteger index;
        
        if (xPos < 0) {
            bookIndex = 0;
            index = 0;
        } else {
            bookIndex = [self bookIndexForPosition:xPos];
            index = [self pathToFlatIndex:CGPointMake(bookIndex, 0)];
        }
        
        [self.cards insertObject:cardView atIndex:index];
        [self.books insertObject:[NSMutableArray arrayWithObject:cardView] atIndex:bookIndex];
    } else {
        NSUInteger index = [self pathToFlatIndex:path];
        [self.cards insertObject:cardView atIndex:index];
        [self.books[(int)path.x] insertObject:cardView atIndex:path.y];
    }
    return [self calculateSpacing];
}

-(void)updateTags {
    NSInteger index = 0;
    for (CardView* view in self.cards) {
        view.tag = index;
        index++;
    }
}

-(NSUInteger)bookIndexForPosition:(CGFloat)xPos {
    NSInteger bookIndex = 0;
    for (NSArray<CardView*>* book in self.books) {
        CGFloat endPos = book[0].frame.origin.x + [book lastObject].frame.size.width;
        if (xPos < endPos) {
            return bookIndex;
        }
        
        bookIndex++;
    }
    
    return [self.books count];
}

-(CGPoint)addIndexForCard:(Card*)card {
    for (int i = 0; i < [self.books count]; i++) {
        NSArray<CardView*>* book = self.books[i];
        NSInteger cardIndex = 0;
        Card* otherCard;
        
        do {
            otherCard = book[cardIndex].card;
            cardIndex++;
        } while (otherCard == nil && cardIndex < [book count]);
        
        if (otherCard != nil && [card.rank isEqualToString:otherCard.rank]) {
            if ([card.suit isEqualToString:otherCard.suit]) {
                return CGPointMake(-1, -1);
            }
            
            return CGPointMake(i, [book count]);
        }
    }
    
    return CGPointMake(-1, -1);
}

-(BOOL)calculateSpacing {
    if ([self.cards count] == 0) {
        return NO;
    }
    
    [self updateTags];
    
    CGFloat maxSpace = self.cardWidth * BOOK_MAX_SPACE;
    CGFloat minSpace = self.cardWidth * BOOK_MIN_SPACE;
        
    NSInteger bookSpacers = [self.books count] - 1;
    CGFloat booksWidth = 0;
    for (NSArray* book in self.books) {
        booksWidth += ( [book count] - 1 ) *  self.sameCardSpace;
        booksWidth += [book count] * self.cardWidth;
    }
    
    CGFloat remainingSpace = self._parentFrame.size.width - booksWidth;
    self.bookSpacerSize = remainingSpace / bookSpacers;
    
    if (self.bookSpacerSize < minSpace) {
        NSLog(@"Too many cards!!");
        self.bookSpacerSize = minSpace;
        return YES;
    } else {
        self.offset = 0;
        
        if (self.bookSpacerSize > maxSpace) {
            self.bookSpacerSize = maxSpace;
            
            CGFloat totalCardsWidth = bookSpacers * self.bookSpacerSize + booksWidth;
            CGFloat midX = self._parentFrame.size.width/2;
            self.offset = midX - totalCardsWidth/2;
        }
    }
    
    return NO;
}

-(CGPoint)flatIndexToPath:(NSUInteger)index {
    NSInteger cardIndex = 0;
    
    for (int i = 0; i < [self.books count]; i++) {
        for (int j = 0; j < [self.books[i] count]; j++) {
            if (index == cardIndex) {
                return CGPointMake(i, j);
            }
            
            cardIndex++;
        }
    }
    
    NSLog(@"unexpected");
    return CGPointMake(-1, -1);
}

-(NSUInteger)pathToFlatIndex:(CGPoint)path {
    if (path.x == [self.books count]) {
        return [self.cards count];
    }
    
    NSUInteger index = 0;
    for (int i = 0; i < path.x; i++) {
        index += [self.books[i] count];
    }
    return index + path.y;
}

@end
