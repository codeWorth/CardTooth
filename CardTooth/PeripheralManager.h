//
//  PeripheralManager.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/22/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "PeripheralData.h"

@protocol PeripheralManagerParent <NSObject>

-(void)cleanup;
-(void)messageRecieved:(NSString*)message;

@end

@interface PeripheralManager : NSObject <CBPeripheralDelegate>

-(instancetype)initWithPeripheral:(PeripheralData*)peripheral andParent:(id<PeripheralManagerParent>)parent;
@property (nonatomic, strong) PeripheralData* peripheral;

-(void)sendMessage:(NSString*)message;

@end
