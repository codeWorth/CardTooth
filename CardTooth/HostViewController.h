//
//  HostViewController.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/20/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBHostManager.h"

@interface HostViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString* game;

@end
