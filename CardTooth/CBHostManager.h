//
//  CBHostManager.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/20/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
#import "PeripheralData.h"
#import "PeripheralManager.h"

@protocol CBManagerDelegate <NSObject>

-(void)messageRecieved:(NSString*)message;
-(void)connected;

@end

@interface CBHostManager : NSObject <CBCentralManagerDelegate, PeripheralManagerParent>

@property (nonatomic, strong) CBCentralManager* manager;
@property (nonatomic, strong) CBPeripheral* wantedPeripheral;
@property (nonatomic, strong) NSMutableArray<PeripheralData*>* peripherals;
@property (nonatomic, weak) id<CBManagerDelegate> delegate;

@property (nonatomic, weak) UITableView* tableView;

-(void)connectTo:(CBPeripheral*)peripheral;
-(void)sendMessage:(NSString*)message toPeripheral:(NSString*)peer;
-(void)sendMessage:(NSString *)message;
-(void)sendMessageToAllPeriperals:(NSString *)message;
-(void)clear;

+(CBHostManager*)instance;
+(void)reset;

@end
