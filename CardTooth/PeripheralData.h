//
//  PeripheralCell.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/20/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PeripheralData : NSObject

-(instancetype)initWithPeripheral:(CBPeripheral*)perip name:(NSString*)name uuid:(NSString*)uuid andStrength:(NSNumber*)strength;
@property (nonatomic, strong) CBPeripheral* peripheral;
@property (nonatomic, strong) NSNumber* signalStrength;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* UUIDString;

@end
