//
//  PeripheralCell.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/22/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeripheralData.h"

@interface PeripheralCell : UITableViewCell

+(NSString*)ri;
-(void)setCellData:(PeripheralData*)data;

@property (nonatomic, strong) PeripheralData* data;

-(void)hideCheckmark;
-(void)showCheckmark;

@end

