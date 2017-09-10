//
//  GoFishViewController.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/30/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBHostManager.h"
#import "CBClientManager.h"
#import "GoFishDataManager.h"
#import "CardBookView.h"

@interface GoFishViewController : UIViewController <CBManagerDelegate, GoFishDataManagerDelegate, CardHandViewDelegate, CardViewDelegate>

@property (nonatomic) BOOL amHost;
@property (nonatomic, strong) NSArray<PeripheralData*>* peers;

@end
