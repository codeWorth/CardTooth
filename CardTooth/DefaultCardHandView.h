//
//  DefaultCardHandView.h
//  CardTooth
//
//  Created by Andrew Cummings on 8/4/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardHandView.h"

@interface DefaultCardHandView : NSObject <CardHandViewDataSource>

-(instancetype)initForFrame:(CGRect)frame;

-(NSArray<Card*>*)getCards;

@end
