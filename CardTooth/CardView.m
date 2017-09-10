//
//  CardView.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/7/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "CardView.h"

@interface CardView ()

@property (nonatomic, strong) Card* _card;
@property (nonatomic) BOOL setup;
@property (nonatomic) BOOL faceUp;

@end

@implementation CardView

-(instancetype)initOnView:(UIView *)view withCard:(Card *)card {
    if (self = [super init]) {
        [view addSubview:self];
        [self setUserInteractionEnabled:YES];
        [self setContentMode:UIViewContentModeScaleToFill];
        
        self.setup = YES;
        self.faceUp = YES;
                
        self._card = card;
        [self setClear:NO];
        
    }
    return self;
}

-(Card*)card {
    return self._card;
}

-(void)setCard:(Card *)card {
    self._card = card;
    
    self.image = [UIImage imageNamed:[self._card imageName]];
    self.layer.borderWidth = 1.0f;
    
    self.faceUp = YES;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    [self.delegate touchMoved:touch forCard:self];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.delegate wasPressed:self];
}

-(void)setPosition:(CGPoint)position {
    [self setPositionX:position.x andY:position.y];
}

-(void)setPositionX:(CGFloat)x andY:(CGFloat)y {
    if (self.setup) {
        [self forceSetPositionX:x andY:y];
        self.setup = NO;
    } else {
        void (^moveCard)() = ^void() {
            self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
        };
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:moveCard completion:nil];
    }
}

-(void)forceSetPositionX:(CGFloat)x andY:(CGFloat)y {
    self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
}

-(void)setSize:(CGSize)size {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

-(void)setSizeWidth:(CGFloat)width andHeight:(CGFloat)height {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
}

-(void)setClear:(BOOL)clear {
    if (clear) {
        self.backgroundColor = [UIColor clearColor];
        [self setUserInteractionEnabled:NO];
        self.layer.borderWidth = 0.0f;
        self.image = nil;
    } else {
        [self setCard:self._card];
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0f;
    }
}

-(void)showBack {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber* imgNumber = (NSNumber*)[defaults objectForKey:@"cardback"];
    if (imgNumber != nil) {
        self.image = [CardView cardBacks][imgNumber.integerValue];
    } else {
        self.image = [UIImage imageNamed:@"cardback1.png"];
    }
    
    self.layer.borderWidth = 0.0f;
    self.faceUp = NO;
}

-(void)flip {
    void (^moveCard)() = ^void() {
        self.layer.transform = CATransform3DRotate(self.layer.transform, M_PI/2, 0, 1, 0);
    };
    void (^completion)(BOOL finished) = ^void(BOOL finished) {
        self.layer.transform = CATransform3DRotate(self.layer.transform, -M_PI, 0, 1, 0);
        if (self.faceUp) {
            [self showBack];
        } else {
            self.card = self._card;
        }
        [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:moveCard completion:nil];
    };
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:moveCard completion:completion];
}

+(NSArray<UIImage*>*)cardBacks {
    return @[[UIImage imageNamed:@"cardback1.png"], [UIImage imageNamed:@"cardback2.png"], [UIImage imageNamed:@"cardback3.png"], [UIImage imageNamed:@"cardback4.png"]];
}

@end
