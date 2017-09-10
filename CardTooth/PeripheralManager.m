//
//  PeripheralManager.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/22/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "PeripheralManager.h"
#import "TRANSFER.h"
#import "CBHostManager.h"

@interface PeripheralManager ()

@property (nonatomic, strong) NSMutableData* data;
@property (nonatomic, weak) id<PeripheralManagerParent> parent;
@property (nonatomic, strong) CBCharacteristic* writeCharacteristic;
@property (nonatomic, strong) NSMutableArray<NSString*>* queuedMessages;
@property (nonatomic) BOOL _canSend;

@end

@implementation PeripheralManager

-(instancetype)initWithPeripheral:(PeripheralData *)peripheral andParent:(id<PeripheralManagerParent>)parent {
    if (self = [super init]) {
        self.peripheral = peripheral;
        self.peripheral.peripheral.delegate = self;
        
        self.queuedMessages = [NSMutableArray array];
        self.data = [[NSMutableData alloc] init];
        [self.data setLength:0];
        
        self.canSend = NO;
        
        self.parent = parent;
        [peripheral.peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
    }
    return self;
}

-(void)setCanSend:(BOOL)_canSend {
    self._canSend = _canSend;
    if (self._canSend == YES) {
        [self sendNextMessage];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        [self cleanup];
        return;
    }
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        [self cleanup];
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:TRANSFER_CHARACTERISTIC_UUID]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        } else if ([characteristic.UUID.UUIDString isEqualToString:TRANSFER_WRITE_UUID]) {
            self.writeCharacteristic = characteristic;
            self.canSend = YES;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error");
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        [self.parent messageRecieved:[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]];
        [self.data setLength:0];
        return;
    }
    
    [self.data appendData:characteristic.value];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
        return;
    }
    
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    } else {
        // Notification has stopped
        [self.parent cleanup];
    }
}

-(void)sendMessage:(NSString *)message {
    [self.queuedMessages insertObject:message atIndex:0];
    [self sendNextMessage];
}

-(void)sendNextMessage {
    if (!self._canSend) return;
    if ([self.queuedMessages count] == 0) return;
    
    [self.peripheral.peripheral writeValue:[[self.queuedMessages lastObject] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    NSLog(@"sending message %@", [self.queuedMessages lastObject]);
    self.canSend = NO;
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"write error");
        return;
    }
    
    if ([characteristic.UUID.UUIDString isEqualToString:TRANSFER_WRITE_UUID]) {
        NSLog(@"write success");
        [self.queuedMessages removeLastObject];
        self.canSend = YES;
    } else {
        NSLog(@"unknown characteristic written");
    }
}

-(void)cleanup {
    for (CBService *service in self.peripheral.peripheral.services) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                if (characteristic.isNotifying) {
                    [self.peripheral.peripheral setNotifyValue:NO forCharacteristic:characteristic];
                    return;
                }
            }
        }
    }
    [self.parent cleanup];
}

@end
