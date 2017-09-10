//
//  Card.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/7/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject

@property (nonatomic, strong) NSString* rank;
@property (nonatomic, strong) NSString* suit;

-(instancetype)initWithSuit:(NSString*)suit andRank:(NSString*)rank;

-(NSString*)imageName;

+(NSArray*)ranks;
+(NSArray*)suits;
+(NSInteger)rankNumber:(NSString*)rank;
+(NSInteger)suitNumber:(NSString*)suit;

@end
