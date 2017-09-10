//
//  CBHostManager.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/20/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "CBHostManager.h"
#import "TRANSFER.h"

@interface CBHostManager ()

@property (nonatomic, strong) NSMutableArray<PeripheralManager*>* connectedPeripherals;

@end

@implementation CBHostManager

static CBHostManager* instance;

-(instancetype)init {
    if (self = [super init]) {
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)];
        self.peripherals = [NSMutableArray array];
        self.connectedPeripherals = [NSMutableArray array];
    }
    return self;
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBManagerStatePoweredOn) {
        [self.manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSArray<NSString*>* nameAndUUID = [[advertisementData objectForKey:CBAdvertisementDataLocalNameKey] componentsSeparatedByString:@":"];
    
    if ([nameAndUUID[0] length] == 0) {
        return;
    }
    
    for (PeripheralData* peripheralData in self.peripherals) {
        if ([peripheralData.UUIDString isEqualToString:nameAndUUID[1]]) {
            return;
        }
    }
    
    PeripheralData* data = [[PeripheralData alloc] initWithPeripheral:peripheral name:nameAndUUID[0] uuid:nameAndUUID[1] andStrength:RSSI];
    
    [self.peripherals addObject:data];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void)connectTo:(CBPeripheral *)peripheral {
    NSLog(@"Connecting to peripheral %@", peripheral);
    self.wantedPeripheral = peripheral;
    [self.manager connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect");
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"connected");
    
    PeripheralData* data;
    for (PeripheralData* thisData in self.peripherals) {
        if ([thisData.peripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            data = thisData;
        }
    }
    
    [self.connectedPeripherals addObject:[[PeripheralManager alloc] initWithPeripheral:data andParent:self]];
    [self.delegate connected];
    [self.manager stopScan];
}

-(void)sendMessage:(NSString *)message {
    NSLog(@"will send message: %@", message);
    [self.connectedPeripherals[0] sendMessage:message];
}

-(void)sendMessage:(NSString *)message toPeripheral:(NSString *)peer {
    for (PeripheralManager* peripheral in self.connectedPeripherals) {
        if ([peripheral.peripheral.UUIDString isEqualToString:peer]) {
            [peripheral sendMessage:message];
            return;
        }
    }
}

-(void)sendMessageToAllPeriperals:(NSString *)message {
    for (PeripheralManager* peripheral in self.connectedPeripherals) {
        [peripheral sendMessage:message];
    }
}

-(void)cleanup {
    for (PeripheralManager* periph in self.connectedPeripherals) {
        [self.manager cancelPeripheralConnection:periph.peripheral.peripheral];
    }
}

-(void)messageRecieved:(NSString *)message {
    [self.delegate messageRecieved:message];
}

-(void)clear {
    [self.peripherals removeAllObjects];
}

+(void)reset {
    [instance.manager stopScan];
    instance = nil;
}


+(CBHostManager*)instance {
    if (instance == nil) {
        instance = [[CBHostManager alloc] init];
    }
    return instance;
}

@end
