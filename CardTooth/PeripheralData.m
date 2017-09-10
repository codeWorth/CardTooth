//
//  PeripheralCell.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/20/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "PeripheralData.h"

@implementation PeripheralData

-(instancetype)initWithPeripheral:(CBPeripheral *)perip name:(NSString *)name uuid:(NSString *)uuid andStrength:(NSNumber *)strength {
    if (self = [super init]) {
        self.signalStrength = strength;
        self.peripheral = perip;
        self.name = name;
        self.UUIDString = uuid;
    }
    return self;
}

@end
