//
//  LoadingView.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/29/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "LoadingView.h"

#define RADIUS 0.25
#define LINE_LENGTH 0.25
#define LINES 12
#define CYCLE_DURATION 0.8

@interface LoadingView ()

@property (nonatomic, strong) CADisplayLink* link;
@property (nonatomic) double lastTime;
@property (nonatomic) BOOL running;

@property (nonatomic) double angle;
@property (nonatomic) double deltaAngelPerSec;
@property (nonatomic) double trailLength;

@property (nonatomic) double lightGray;
@property (nonatomic) double grayDif;

@end

@implementation LoadingView

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
        self.angle = 0;
        self.deltaAngelPerSec = 2 * M_PI / CYCLE_DURATION;
        self.trailLength = M_PI / 1.7;
        
        self.lightGray = 0.7;
        self.grayDif = -0.5;
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self setOpaque:NO];
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect {
    if (!self.running) {
        [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        self.running = YES;
        return;
    }
    if (self.lastTime == 0) {
        self.lastTime = self.link.timestamp;
        return;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1.5);
    
    double dT = self.link.timestamp - self.lastTime;
    self.lastTime = self.link.timestamp;
    double dA = self.deltaAngelPerSec * dT; //delta angle
    self.angle += dA;
    if (self.angle < 0) {
        self.angle = M_PI * 2;
    } else if (self.angle > M_PI * 2) {
        self.angle = 0;
    }
    
    double innerRadius = self.frame.size.width * RADIUS;
    double lineLength = self.frame.size.width * LINE_LENGTH;
    
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);
    
    for (int i = 0; i < LINES; i++) {
        double angle = 2 * M_PI / LINES * i;
        double dX = cos(angle) * innerRadius;
        double dY = sin(angle) * innerRadius;
        CGContextMoveToPoint(ctx, center.x + dX, center.y + dY);
        
        dX = cos(angle) * (innerRadius + lineLength);
        dY = sin(angle) * (innerRadius + lineLength);
        CGContextAddLineToPoint(ctx, center.x + dX, center.y + dY);
        
        double color = self.lightGray;
        
        double angleDif = self.angle - angle;
        if (angleDif <= self.trailLength && angleDif >= 0) {
            double percent = angleDif / self.trailLength;
            color += (1 - percent) * self.grayDif;
        } else {
            angleDif += 2 * M_PI;
            if (angleDif <= self.trailLength && angleDif >= 0) {
                double percent = angleDif / self.trailLength;
                color += (1 - percent) * self.grayDif;
            }
        }
        [[UIColor colorWithWhite:color alpha:1] setStroke];
        
        CGContextStrokePath(ctx);
    }
}

-(void)stop {
    [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

@end
