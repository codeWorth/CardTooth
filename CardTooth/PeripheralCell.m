//
//  PeripheralCell.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/22/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "PeripheralCell.h"

@interface PeripheralCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *wifiImage;
@property (weak, nonatomic) IBOutlet UIImageView *rightmostIcon;

@end

@implementation PeripheralCell

-(void)setCellData:(PeripheralData *)data {
    self.data = data;
    
    self.nameLabel.text = data.name;
    
    if (data.signalStrength.integerValue < -65) {
        self.wifiImage.image = [UIImage imageNamed:@"wifiLow.png"];
    } else if (data.signalStrength.integerValue < -35) {
        self.wifiImage.image = [UIImage imageNamed:@"wifiMedium.png"];
    } else {
        self.wifiImage.image = [UIImage imageNamed:@"wifiHigh.png"];
    }
    
    self.rightmostIcon.image = nil;
}

+(NSString*)ri {
    return @"peripheral";
}

-(void)showCheckmark {
    self.rightmostIcon.image = [UIImage imageNamed:@"checkmark.png"];
}

-(void)hideCheckmark {
    self.rightmostIcon.image = nil;
}

@end
