//
//  BooksViewController.h
//  CardTooth
//
//  Created by Andrew Cummings on 7/30/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"

@interface BooksViewController : UIViewController

@property (nonatomic, strong) NSArray<NSArray<Card*>*>* books;
@property (nonatomic, strong) NSArray<NSString*>* names;

@end
