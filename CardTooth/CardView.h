//
//  CardView.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/7/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
@class CardView;

@protocol CardViewDelegate <NSObject>

-(void)wasPressed:(CardView*)cardView;
-(void)touchMoved:(UITouch*)touch forCard:(CardView*)cardView;

@end

@interface CardView : UIImageView

-(instancetype)initOnView:(UIView*)view withCard:(Card*)card;
@property (nonatomic, weak) id<CardViewDelegate> delegate;
@property (nonatomic) BOOL shouldReturn;

-(Card*)card;
-(void)setCard:(Card *)card;

-(void)setPosition:(CGPoint)position;
-(void)setPositionX:(CGFloat)x andY:(CGFloat)y;
-(void)forceSetPositionX:(CGFloat)x andY:(CGFloat)y;

-(void)setSizeWidth:(CGFloat)width andHeight:(CGFloat)height;
-(void)setSize:(CGSize)size;

-(void)setClear:(BOOL)clear;

-(void)showBack;
-(void)flip;

+(NSArray<UIImage*>*)cardBacks;

@end
