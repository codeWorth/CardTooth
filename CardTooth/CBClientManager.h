//
//  CBClientManager.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/20/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBHostManager.h"

@interface CBClientManager : NSObject <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager* manager;
@property (nonatomic, weak) id<CBManagerDelegate> delegate;

-(void)sendMessage:(NSString*)message;

+(CBClientManager*)instance;
+(void)reset;

@end
