//
//  GinRummyClient.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/28/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GinRummy.h"

@interface GinRummyClient : GinRummy

-(instancetype)initWithDelegate:(id<GinRummyDelegate>)delegate;
-(void)beginGame:(NSArray<Card*>*)cards p1Hand:(NSArray<Card*>*)p1Hand andP1:(BOOL)p1;

@end
