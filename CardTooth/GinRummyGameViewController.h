//
//  GameViewController.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/22/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeripheralData.h"
#import "CardHandView.h"
#import "CBHostManager.h"
#import "GinRummy.h"
#import "CardView.h"
#import "DataManager.h"


@interface GinRummyGameViewController : UIViewController <CBManagerDelegate, UITextFieldDelegate, GinRummyDelegate, CardViewDelegate, CardHandViewDelegate, DataManagerGameDelegate>

@property (nonatomic) BOOL amHost;

@end
