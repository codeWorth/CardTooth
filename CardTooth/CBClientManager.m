//
//  CBClientManager.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/20/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "CBClientManager.h"
#import "TRANSFER.h"

@interface CBClientManager ()

@property (nonatomic, strong) NSMutableArray<NSData*>* dataArray;
@property (nonatomic) NSInteger dataIndex;
@property (nonatomic) BOOL _canSend;

@property (nonatomic, strong) CBMutableCharacteristic* transferCharacteristic;

@end

@implementation CBClientManager

static CBClientManager* instance;

-(instancetype)init {
    if (self = [super init]) {
        self.manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)];
        self.dataArray = [NSMutableArray array];
        self.canSend = NO;
    }
    return self;
}

-(BOOL)canSend {
    return self._canSend;
}

-(void)setCanSend:(BOOL)_canSend {
    self._canSend = _canSend;
    if (_canSend == YES) {
        if([self.dataArray count] > 0) {
            [self.dataArray removeObjectAtIndex:0];
        }
        self.dataIndex = 0;
        [self sendData];
    }
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBManagerStatePoweredOn) {
        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
        CBMutableCharacteristic* writeCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_WRITE_UUID] properties:CBCharacteristicPropertyWrite|CBCharacteristicPropertyRead|CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
        
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
        
        transferService.characteristics = @[self.transferCharacteristic, writeCharacteristic];
        
        [self.manager addService:transferService];
    }
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"error");
        return;
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* name = [defaults objectForKey:@"name"];
    if (name == nil) {
        name = [[UIDevice currentDevice] name];
    }
    name = [NSString stringWithFormat:@"%@:%@", name, [[[UIDevice currentDevice] identifierForVendor].UUIDString substringToIndex:5]];
    
    
    if ([service.UUID.UUIDString isEqualToString:TRANSFER_SERVICE_UUID]) {
        [self.manager startAdvertising:@{ CBAdvertisementDataLocalNameKey: name, CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
    }
}

-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"Did not start advertising");
        return;
    }
    
    NSLog(@"began advertising");
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    if ([characteristic.UUID.UUIDString isEqualToString:TRANSFER_CHARACTERISTIC_UUID]) {
        [self.manager stopAdvertising];
        [self.delegate connected];
        NSLog(@"central connected, stopped advertising");
        self.canSend = YES;
    } else {
        NSLog(@"unknown characteristic");
    }
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    CBATTRequest* firstRequest = requests[0];
    
    if (![firstRequest.characteristic.UUID.UUIDString isEqualToString:TRANSFER_WRITE_UUID]) {
        NSLog(@"wrong characteristic");
        return;
    }
    
    NSString* sentMessage = [[NSString alloc] initWithData: firstRequest.value encoding:NSUTF8StringEncoding];
    NSLog(@"data recieved: %@", sentMessage);
    [self.delegate messageRecieved:sentMessage];
    [peripheral respondToRequest:firstRequest withResult:CBATTErrorSuccess];
}

- (void)sendData {
    
    if ([self.dataArray count] == 0) {
        return;
    }
    NSData* data = self.dataArray[0];
    self.canSend = NO;
    
    static BOOL sendingEOM = NO;
    
    // end of message?
    if (sendingEOM) {
        BOOL didSend = [self.manager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        if (didSend) {
            self.canSend = YES;
            sendingEOM = NO;
        }
        // didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    if (self.dataIndex >= data.length) {
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    BOOL didSend = YES;
    
    while (didSend) {
        NSInteger amountToSend = data.length - self.dataIndex;
        
        if (amountToSend > NOTIFY_MTU) {
            amountToSend = NOTIFY_MTU;
        }
        NSData *chunk = [NSData dataWithBytes:data.bytes + self.dataIndex length:amountToSend];
        didSend = [self.manager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        if (!didSend) {
            return;
        }
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent: %@", stringFromData);
        
        // It did send, so update our index
        self.dataIndex += amountToSend;
        
        // Was it the last one?
        if (self.dataIndex >= data.length) {
            BOOL eomSent = [self.manager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                sendingEOM = NO;
                self.canSend = YES;
            } else {
                // Set this so if the send fails, we'll send it next time
                sendingEOM = YES;
            }
            return;
        }
    }
}

-(void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    [self sendData];
}

-(void)sendMessage:(NSString *)message {
    [self.dataArray addObject:[message dataUsingEncoding:NSUTF8StringEncoding]];
    if (self._canSend) {
        [self sendData];
    }
}

+(CBClientManager*)instance {
    if (instance == nil) {
        instance = [[CBClientManager alloc] init];
    }
    return instance;
}

+(void)reset {
    [instance.manager stopAdvertising];
    instance = nil;
}

@end
