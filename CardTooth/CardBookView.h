//
//  CardBookView.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/30/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "CardHandView.h"

@interface CardBookView : NSObject <CardHandViewDataSource>

-(instancetype)initForFrame:(CGRect)frame;

@end
