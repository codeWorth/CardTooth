//
//  BooksViewController.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/30/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "BooksViewController.h"
#import "CardBookView.h"

@interface BooksViewController ()

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *nameLabels;
@property (strong, nonatomic) IBOutletCollection(CardHandView) NSArray *bookViews;


@end

@implementation BooksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self arrangeCollectionsByTag];
    
    for (int i = 0; i < [self.books count]; i++) {
        UILabel* label = self.nameLabels[i];
        label.text = self.names[i];
        
        CardHandView* view = self.bookViews[i];
        [view setDataSourceInitialObject:[[CardBookView alloc] initForFrame:view.frame]];
        for (Card* card in self.books[i]) {
            [view addCard:card];
        }
    }
}

-(void)arrangeCollectionsByTag {
    self.bookViews = [self.bookViews sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        return [@(view1.tag) compare:@(view2.tag)];
    }];
    self.nameLabels = [self.nameLabels sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        return [@(view1.tag) compare:@(view2.tag)];
    }];
}

@end
