//
//  GoFishClient.h
//  CardTooth
//
//  Created by Andrew Cummings on 8/6/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "GoFish.h"

@interface GoFishClient : GoFish

-(instancetype)initWithMeUUID:(NSString*)me;
-(void)beginGameWithCards:(NSArray<Card*>*)cards playerOrder:(NSArray<NSString*>*)playerUUIDs me:(NSString*)meUUID andHand:(NSArray*)hand;

@end
