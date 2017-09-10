//
//  HomeScreenViewController.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/29/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "HomeScreenViewController.h"
#import "HostViewController.h"
#import "Card.h"

@interface HomeScreenViewController ()

@property (nonatomic, strong) NSArray* games;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@end

@implementation HomeScreenViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.games = @[@"Gin Rummy", @"Go Fish", @"Crazy Eights", @"Cambio"];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    NSArray<Card*>* winning10 = @[
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"7"],
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"2"],
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"3"],
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"8"],
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"4"],
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"9"],
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"10"],
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"6"],
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"jack"],
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"5"]
                                  ];
    
    NSArray<Card*>* winning73Mix = @[
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"7"],
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"2"],
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"3"],
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"8"],
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"4"],
                                  [[Card alloc] initWithSuit:@"diamonds" andRank:@"2"],
                                  [[Card alloc] initWithSuit:@"spades" andRank:@"2"],
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"6"],
                                  [[Card alloc] initWithSuit:@"clubs" andRank:@"2"],
                                  [[Card alloc] initWithSuit:@"hearts" andRank:@"5"]
                                  ];
    
    NSArray<Card*>* winning334Mix = @[
                                      [[Card alloc] initWithSuit:@"spades" andRank:@"3"],
                                      [[Card alloc] initWithSuit:@"clubs" andRank:@"5"],
                                      [[Card alloc] initWithSuit:@"hearts" andRank:@"4"],
                                      [[Card alloc] initWithSuit:@"spades" andRank:@"2"],
                                      [[Card alloc] initWithSuit:@"hearts" andRank:@"3"],
                                      [[Card alloc] initWithSuit:@"spades" andRank:@"5"],
                                      [[Card alloc] initWithSuit:@"clubs" andRank:@"4"],
                                      [[Card alloc] initWithSuit:@"hearts" andRank:@"2"],
                                      [[Card alloc] initWithSuit:@"clubs" andRank:@"6"],
                                      [[Card alloc] initWithSuit:@"spades" andRank:@"4"]
                                     ];
    
    //NSLog(@"Hand of 10 in a row: %@", [self canWin:winning10 withGroups:[NSMutableArray array]] ? @"wins" : @"doesn't win");
    //NSLog(@"Hand of 7 in a row and 3 set: %@", [self canWin:winning73Mix withGroups:[NSMutableArray array]] ? @"wins" : @"doesn't win");
    NSLog(@"Hand of 3 3 and 4 all mixed up: %@", [self canWin:winning334Mix withGroups:[NSMutableArray array]] ? @"wins" : @"doesn't win");
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.games count];
}

-(NSAttributedString*)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    UIColor* color = [UIColor colorWithWhite:0.8 alpha:1];
    return [[NSAttributedString alloc] initWithString:self.games[row] attributes:@{NSForegroundColorAttributeName:color}];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"host"]) {
        HostViewController* controller = (HostViewController*)segue.destinationViewController;
        controller.game = self.games[[self.pickerView selectedRowInComponent:0]];
    }
}


-(BOOL)canWin:(NSArray<Card*>*)cards withGroups:(NSArray*)groups {
    if ([cards count] == 0) {
        for (NSArray* group in groups) { //Check if all groups have at least 3 cards
            if ([group count] < 3) {
                return NO;
            }
        }
        return YES;
    }
    
    Card* card = cards[0];
    NSArray* newCards = [cards subarrayWithRange:NSMakeRange(1, [cards count] - 1)]; //remove first card from cards and make a copy of the array
    
    //checks whether card belongs in an existing group
    for (int i = 0; i < [groups count]; i++) {
        if ([self canAddCard:card toGroup:groups[i]]) {
            NSMutableArray* newGroups = [groups mutableCopy]; //don't want to change the original array so it can be used each time
            [newGroups[i] addObject:card]; //add to correct group
            if ([self canWin:newCards withGroups:newGroups]) { //recursive call, check if the situation is winnable
                return YES;
            }
        }
    }
    
    //if we didn't already win, checks whether card belongs in a new group
    NSMutableArray* newGroups = [groups mutableCopy];
    [newGroups addObject:[NSMutableArray arrayWithObject:card]]; // make new group and add it
    if ([self canWin:newCards withGroups:newGroups]) { //recursive call, check if the situation is winnable
        return YES;
    }
    
    return NO; //if we haven't won by now, then we can't win with this option
}

-(BOOL)canAddCard:(Card*)card toGroup:(NSArray<Card*>*)group {
    if ([group count] == 0) {
        return NO;
    }
    
    if (card.rank == group[0].rank) {
        return YES;
    } else if (card.suit == group[0].suit) {
        for (Card* groupCard in group) {
            NSInteger groupCardNum = [Card rankNumber:groupCard.rank];
            NSInteger cardNum = [Card rankNumber:card.rank];
            if (cardNum + 1 == groupCardNum || cardNum - 1 == groupCardNum) {
                return YES;
            }
        }
        return NO;
    } else {
        return NO;
    }
}

@end
