//
//  CardHandView.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/27/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "CardHandView.h"
#import <math.h>

#define ASPECT_RATIO 0.7

@interface CardHandView ()

@property (nonatomic) CGPoint draggingOffset;
@property (nonatomic) BOOL dragging;
@property (nonatomic, strong) CardView* clearCard;

@property (nonatomic) BOOL outside;
@property (nonatomic, strong) CardView* poppedCard;

@property (nonatomic, strong) NSMutableArray<id<CardHandViewDataSource>>* dataSources;
@property (nonatomic, strong) id<CardHandViewDataSource> _activeDataSource;

@end

@implementation CardHandView

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.dragging = NO;
        self.outside = NO;
        self.layer.cornerRadius = 5;
        self.dataSources = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repositionCards) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

-(void)addCard:(Card *)card {
    CardView* view = [[CardView alloc] initOnView:self withCard:card];
    view.delegate = self;
    [self._activeDataSource addCardView:view forPosition:-1];
    [self repositionCards];
}

-(void)addCardView:(CardView *)cardView forPosition:(NSInteger)xPos {
    [cardView removeFromSuperview];
    [self addSubview:cardView];
    cardView.delegate = self;
    [self._activeDataSource addCardView:cardView forPosition:xPos];
    [self repositionCards];
}

-(void)repositionCards {
    for( int i = 0; i < [self._activeDataSource cardCount]; i++) {
        CardView* view = [self._activeDataSource cardViewForIndex:i];
        [view setPositionX:[self._activeDataSource positionForIndex:i] andY:0];
        [self bringSubviewToFront:view];
    }
}

-(void)toFront {
    for( int i = 0; i < [self._activeDataSource cardCount]; i++) {
        CardView* view = [self._activeDataSource cardViewForIndex:i];
        [self bringSubviewToFront:view];
    }
}

-(void)wasPressed:(CardView *)cardView {
    if (self.clearCard != nil) {
        if (self.outside) {
            void (^moveCard)() = ^void() {
                [cardView forceSetPositionX:self.clearCard.frame.origin.x + self.frame.origin.x andY:self.frame.origin.y];
            };
            void (^completion)(BOOL finished) = ^void(BOOL finished) {
                [self returnCard:cardView];
            };
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:moveCard completion:completion];
        } else {
            self.dragging = NO;
            [self._activeDataSource replaceCardView:cardView forIndex:self.clearCard.tag];
            self.clearCard = nil;
            [self toFront];
        }
    } else if (self.outside) {
        if ([self.delegate cardView:self outsideReleased:self.poppedCard]) {
            [self releaseOutsideCard];
        } else if (cardView.shouldReturn) {
            [self._activeDataSource addCardView:self.poppedCard forPosition:0];
            CardView* cardView = self.poppedCard;
            [self releaseOutsideCard];
            [self addSubview:cardView];
            [self repositionCards];
        }
    }
}

-(void)releaseOutsideCard {
    if ([self.subviews containsObject:self.poppedCard] || [self.superview.subviews containsObject:self.poppedCard]) {
        [self.poppedCard removeFromSuperview];
    }
    
    self.poppedCard = nil;
    self.dragging = NO;
    self.outside = NO;
    self.clearCard = nil;
    [self repositionCards];
}

-(void)touchMoved:(UITouch *)touch forCard:(CardView *)cardView {
    if (!self.dragging && !self.outside) {
        self.draggingOffset = [touch locationInView:cardView];
        [self bringSubviewToFront:cardView];
        [self replaceWithClear:cardView.tag];
        self.dragging = YES;
    }
    
    if (self.outside) {
        CGPoint pos = [touch locationInView:self.superview];
        [cardView setPositionX:pos.x - self.draggingOffset.x andY:pos.y - self.draggingOffset.y];
        
        if ([self._activeDataSource cardInRangeForPosition:pos]) {
            [self returnCard:cardView];
            return;
        }
        
        if (self.clearCard == nil) {
            if ([self._activeDataSource cardNearRangeForPosition:pos]) {
                [self addNewClearCard:cardView.card atPosition:cardView.frame.origin.x - self.frame.origin.x];
            }
        } else if (![self._activeDataSource cardNearRangeForPosition:pos]) {
            [self._activeDataSource removeCardView:self.clearCard];
            [self.clearCard removeFromSuperview];
            self.clearCard = nil;
            [self repositionCards];
        }
    } else {
        [self bringSubviewToFront:cardView];
        
        CGPoint pos = [touch locationInView:self];
        [cardView setPositionX:pos.x - self.draggingOffset.x andY:0];
        
        if (![self._activeDataSource cardInRangeForPosition:[touch locationInView:self.superview]]) {
            [self popCardOut:cardView];
            return;
        }
    }
    
    if (self.clearCard != nil) {
        NSUInteger xPos;
        if (self.outside) {
            xPos = cardView.frame.origin.x - self.frame.origin.x;
        } else {
            xPos = cardView.frame.origin.x;
        }
        
        if ([self._activeDataSource card:cardView.card atSlot:self.clearCard.tag needsMove:xPos]) {
            CardView* oldClear = self.clearCard; //save old clear card
            
            [self addNewClearCard:cardView.card atPosition:xPos];
            [self._activeDataSource removeCardView:oldClear];
            [self repositionCards];
        }
    }
}

-(void)addNewClearCard:(Card*)card atPosition:(CGFloat)xPos {
    self.clearCard = [[CardView alloc] initOnView:self withCard:card];
    [self.clearCard setClear:YES];
    
    [self._activeDataSource addCardView:self.clearCard forPosition:xPos];
    [self repositionCards];
}

-(void)replaceWithClear:(NSInteger)pos {
    CardView* clear = [[CardView alloc] initOnView:self withCard:nil];
    [clear setClear:YES];
    clear.tag = pos;
    self.clearCard = clear;
    [self addSubview:self.clearCard];
    
    CardView* toTop = [self._activeDataSource replaceCardView:self.clearCard forIndex:pos];
    [self bringSubviewToFront:toTop];
}

-(void)popCardOut:(CardView*)card {
    self.poppedCard = card;
    CGPoint position = card.frame.origin;
    
    [self._activeDataSource removeCardView:self.clearCard];
    self.clearCard = nil;
    
    [self.superview addSubview:card];
    [card forceSetPositionX:position.x + self.frame.origin.x andY:position.y + self.frame.origin.y];
    self.outside = YES;
    
    [self repositionCards];
}

-(void)returnCard:(CardView*)card {
    CGPoint position = card.frame.origin;
    
    [card removeFromSuperview];
    [self addSubview:card];
    [card forceSetPositionX:position.x - self.frame.origin.x andY:0];
    
    [self._activeDataSource addCardView:card forPosition:card.frame.origin.x];

    if (self.clearCard != nil) {
        [self._activeDataSource removeCardView:self.clearCard];
        self.clearCard = nil;
        [self repositionCards];
    }
    
    [self repositionCards];
    
    self.outside = NO;
    self.dragging = NO;
}

-(void)pickUpCard:(CardView*)card referencePos:(CGPoint)pos{
    self.poppedCard = card;
    
    //[self.poppedCard showBack];
    [self.poppedCard setClear:NO];
    //[self.poppedCard flip];
    
    [self.superview bringSubviewToFront:self.poppedCard];
    
    self.dragging = YES;
    self.outside = YES;
    self.draggingOffset = pos;
    
    card.delegate = self;
}

-(id<CardHandViewDataSource>)activeDataSource {
    return self._activeDataSource;
}

-(void)setDataSourceInitialObject:(id<CardHandViewDataSource>)dataSource {
    [self.dataSources addObject:dataSource];
    self._activeDataSource = [self.dataSources lastObject];
}

-(void)addDataSource {
    id<CardHandViewDataSource> new = [[[self._activeDataSource class] alloc] init];
    [new setParentFrame:self.frame];
    [self.dataSources addObject:new];
}

@end
