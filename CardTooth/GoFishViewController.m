//
//  GoFishViewController.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/30/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "GoFishViewController.h"
#import "GoFish.h"
#import "DefaultCardHandView.h"
#import "CardBookView.h"
#import "GoFishClient.h"
#import "BooksViewController.h"

@interface GoFishViewController ()

@property (weak, nonatomic) IBOutlet CardHandView *handView;
@property (weak, nonatomic) IBOutlet UIImageView *askCardImageView;
@property (weak, nonatomic) IBOutlet UIView *askCardView;
@property (nonatomic) NSInteger x;
@property (weak, nonatomic) IBOutlet UILabel *askCardText;
@property (weak, nonatomic) IBOutlet UIImageView *drawPileImage;
@property (weak, nonatomic) IBOutlet CardHandView *myBooksView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *handSelector;
@property (weak, nonatomic) IBOutlet UIButton *booksButton;
@property (weak, nonatomic) IBOutlet UIButton *beginButton;
@property (weak, nonatomic) IBOutlet UIView *askOthersView;
@property (weak, nonatomic) IBOutlet UIButton *p1Button;
@property (weak, nonatomic) IBOutlet UIButton *p2Button;
@property (weak, nonatomic) IBOutlet UIButton *p3Button;
@property (weak, nonatomic) IBOutlet UIButton *p4Button;
@property (weak, nonatomic) IBOutlet UILabel *turnLabel;
@property (weak, nonatomic) IBOutlet UIView *wantedView;
@property (weak, nonatomic) IBOutlet UILabel *askingPlayerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankWantedLabel;
@property (weak, nonatomic) IBOutlet UILabel *wantsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *askLeading;

@property (nonatomic, strong) GoFishDataManager* dataManager;
@property (nonatomic, strong) GoFish* game;
@property (nonatomic) NSInteger connectedPeers;

@property (nonatomic, strong) NSMutableArray<NSString*>* otherPlayerUUIDs;
@property (nonatomic, strong) NSString* selectedPlayerUUID;
@property (nonatomic, strong) UIButton* buttonSelected;
@property (nonatomic, strong) NSString* wantedRank;

@property (nonatomic, strong) NSMutableArray<NSArray<Card*>*>* recievedBooks;
@property (nonatomic, strong) NSMutableArray<NSString*>* recievedNames;

@property (nonatomic, strong) CardView* askCard;
@property (nonatomic, strong) NSArray<Card*>* recievedCards;
@property (nonatomic) NSInteger recievedCardsIndex;
@property (nonatomic) BOOL putCard;

@property (nonatomic, strong) CardView* drawCard;

@property (nonatomic, strong) NSDictionary* playerNames;

@end

@implementation GoFishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.amHost) {
        [CBHostManager instance].delegate = self;
    } else {
        [CBClientManager instance].delegate = self;
    }
    
    self.booksButton.enabled = NO;
    self.askCardImageView.backgroundColor = self.handView.backgroundColor;
    self.askCardView.hidden = YES;
    self.handView.delegate = self;
    self.myBooksView.delegate = self;
    self.askCardView.hidden = YES;
    self.askCardImageView.image = [UIImage imageNamed:@"blankcard.png"];
    self.handSelector.hidden = YES;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber* imgNumber = (NSNumber*)[defaults objectForKey:@"cardback"];
    if (imgNumber != nil) {
        self.drawPileImage.image = [CardView cardBacks][imgNumber.integerValue];
    }
    
    if (self.amHost) {
        NSMutableArray* uuids = [NSMutableArray array];
        NSMutableDictionary* playersDict = [NSMutableDictionary dictionary];
        for (PeripheralData* data in self.peers) {
            NSString* name = data.name;
            NSString* uuid = data.UUIDString;
            [uuids addObject:uuid];
            [playersDict setObject:name forKey:uuid];
        }
        
        NSString* name = [[UIDevice currentDevice] name];
        NSString* uuid = [[[UIDevice currentDevice] identifierForVendor].UUIDString substringToIndex:5];
        [playersDict setObject:name forKey:uuid];
        
        self.playerNames = playersDict;
        [uuids addObject:[[[UIDevice currentDevice] identifierForVendor].UUIDString substringToIndex:5]];
        
        self.game = [[GoFish alloc] initWithPlayers:uuids];
    } else {
        self.game = [[GoFishClient alloc] initWithMeUUID:[[[UIDevice currentDevice] identifierForVendor].UUIDString substringToIndex:5]];
        [self.beginButton removeFromSuperview];
        self.beginButton = nil;
    }
    self.dataManager = [[GoFishDataManager alloc]initAsHost:self.amHost withGame:self.game];
    self.dataManager.delegate = self;
    
    self.recievedBooks = [NSMutableArray array];
    self.recievedNames = [NSMutableArray array];
}

-(void)player:(NSString *)askerUUID wantsRank:(NSInteger)rank {
    self.wantedRank = [Card ranks][rank];
    
    if (![self.game hasAnyOfRank:self.wantedRank]) {
        self.wantedRank = nil;
        [self.dataManager sentLastCard];
        
        [self hideAsk];
        return;
    }
    
    self.askingPlayerNameLabel.text = self.playerNames[askerUUID];
    self.rankWantedLabel.text = [self.wantedRank capitalizedString];
    
    self.askCardImageView.image = [UIImage imageNamed:@"blankcard.png"];
    self.askCardText.text = @"Cards Here";
    [self showAsk];
    
    void (^setAlpha)() = ^void() {
        self.wantedView.alpha = 1;
    };
    [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:setAlpha completion:nil];
}

-(void)hideAsk {
    [self.view layoutIfNeeded];
    void (^move)() = ^void() {
        self.askLeading.constant = -self.askCardView.frame.size.width;
        [self.view layoutIfNeeded];

    };
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:move completion:nil];
}

-(void)showAsk {
    self.askCardView.hidden = NO;
    
    [self.view layoutIfNeeded];
    void (^move)() = ^void() {
        self.askLeading.constant = 8;
        [self.view layoutIfNeeded];
        
    };
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:move completion:nil];
}

-(void)hand:(NSArray<Card *> *)hand {
    for (Card* card in hand) {
        [self.handView addCard:card];
    }
}

-(void)playerUUIDs:(NSArray<NSString *> *)uuids andNames:(NSArray<NSString *> *)names {
    NSMutableDictionary* playersDict = [NSMutableDictionary dictionary];
    for (int i = 0; i < [uuids count]; i++) {
        [playersDict setObject:names[i] forKey:uuids[i]];
    }
    self.playerNames = playersDict;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.handView.activeDataSource == nil) {
        self.x = self.askCardView.frame.origin.x;
        [self.handView setDataSourceInitialObject:[[DefaultCardHandView alloc] initForFrame:self.handView.frame]];
        [self.myBooksView setDataSourceInitialObject:[[CardBookView alloc] initForFrame:self.myBooksView.frame]];
    }
    if (self.askCardImageView.hidden) {
        [self hideAsk];
    }
}

-(void)startGame {
    self.otherPlayerUUIDs = [NSMutableArray arrayWithArray:self.game.playerUUIDs];
    [self.otherPlayerUUIDs removeObject:self.game.meUUID];
    NSInteger players = [self.otherPlayerUUIDs count];
    if (players > 3) {
        self.p4Button.hidden = NO;
        [self.p4Button setTitle:self.playerNames[self.otherPlayerUUIDs[3]] forState:UIControlStateNormal];
    }
    if (players > 2) {
        self.p3Button.hidden = NO;
        [self.p3Button setTitle:self.playerNames[self.otherPlayerUUIDs[2]] forState:UIControlStateNormal];
    }
    if (players > 1) {
        self.p2Button.hidden = NO;
        [self.p2Button setTitle:self.playerNames[self.otherPlayerUUIDs[1]] forState:UIControlStateNormal];
    }
    if (players > 0) {
        self.p1Button.hidden = NO;
        [self.p1Button setTitle:self.playerNames[self.otherPlayerUUIDs[0]] forState:UIControlStateNormal];
    }
    
    NSMutableArray<NSString*>* orderedNames = [NSMutableArray array];
    for (NSString* uuid in self.game.playerUUIDs) {
        [orderedNames addObject:self.playerNames[uuid]];
    }
    
    [self remakeCardPile];
    
    if (self.amHost) {
        [self.dataManager sendPlayerNames:orderedNames];
        [self.dataManager sendBeginGame];
    }
    [self updateTurn];
}

-(void)connected {
    [self performSelectorOnMainThread:@selector(handleConnected) withObject:nil waitUntilDone:NO];
}
-(void)handleConnected {
    if (self.amHost) {
        self.connectedPeers++;
        if (self.connectedPeers == [self.peers count]) {
            self.beginButton.enabled = YES;
            [self.dataManager sendGame];
        }
    }
    
    //self.concedeButton.enabled = YES;
}

-(void)messageRecieved:(NSString *)message {
    [self performSelectorOnMainThread:@selector(passAlong:) withObject:message waitUntilDone:YES];
}

-(void)passAlong:(NSString *)message {
    [self.dataManager processRecievedMessage:message];
}

-(IBAction)begin {
    if (self.amHost) {
        [self.game beginGame];
        [self.beginButton removeFromSuperview];
    }
}

- (IBAction)ask:(UIButton *)sender {
    NSString* uuid = self.otherPlayerUUIDs[sender.tag];
    
    if ([self.selectedPlayerUUID isEqualToString:uuid]) {
        self.selectedPlayerUUID = nil;
        self.buttonSelected = nil;
        sender.backgroundColor = [UIColor clearColor];
        [self hideAsk];
        return;
    }
    
    if (self.putCard || self.game.canAsk == NO) {
        return;
    }
    
    if (self.selectedPlayerUUID == nil) {
        self.selectedPlayerUUID = uuid;
        self.buttonSelected = sender;
        sender.backgroundColor = [UIColor colorWithRed:1 green:1 blue:117/255 alpha:0.34];
        self.askCardImageView.image = [UIImage imageNamed:@"blankcard.png"];
        self.askCardText.text = @"Card Here";
        [self showAsk];
    } else {
        self.buttonSelected.backgroundColor = [UIColor clearColor];
        self.buttonSelected = sender;
        self.selectedPlayerUUID = uuid;
        sender.backgroundColor = [UIColor colorWithRed:1 green:1 blue:117/255 alpha:0.34];
        self.askCardImageView.image = [UIImage imageNamed:@"blankcard.png"];
        self.askCardText.text = @"Card Here";
        [self showAsk];
    }
}

-(BOOL)cardView:(CardHandView *)view outsideReleased:(CardView *)cardView {
    CGPoint adjustedPos = CGPointMake(cardView.frame.origin.x + cardView.frame.size.width/2, cardView.frame.origin.y + cardView.frame.size.height/2);
    
    CGPoint bottomRight = CGPointMake(self.myBooksView.frame.origin.x + self.myBooksView.frame.size.width, self.myBooksView.frame.origin.y + self.myBooksView.frame.size.height);
    
    if (adjustedPos.x > self.myBooksView.frame.origin.x && adjustedPos.x < bottomRight.x && adjustedPos.y > self.myBooksView.frame.origin.y && adjustedPos.y < bottomRight.y) {
        [cardView forceSetPositionX:cardView.frame.origin.x - self.myBooksView.frame.origin.x andY:cardView.frame.origin.y - self.myBooksView.frame.origin.y];
        [self.myBooksView addCardView:cardView forPosition:cardView.frame.origin.x - self.myBooksView.frame.origin.x];
        return YES;
    }
    
    bottomRight = CGPointMake(self.handView.frame.origin.x + self.handView.frame.size.width, self.handView.frame.origin.y + self.handView.frame.size.height);
    
    if (adjustedPos.x > self.handView.frame.origin.x && adjustedPos.x < bottomRight.x && adjustedPos.y > self.handView.frame.origin.y && adjustedPos.y < bottomRight.y) {
        [cardView forceSetPositionX:cardView.frame.origin.x - self.handView.frame.origin.x andY:cardView.frame.origin.y - self.handView.frame.origin.y];
        [self.handView addCardView:cardView forPosition:cardView.frame.origin.x - self.handView.frame.origin.x];
        return YES;
    }
    
    if (self.selectedPlayerUUID == nil && self.wantedRank == nil) {
        return NO;
    }
    
    bottomRight = CGPointMake(self.askCardView.frame.origin.x + self.askCardView.frame.size.width, self.askCardView.frame.origin.y + self.askCardView.frame.size.height);
    
    
    if (adjustedPos.x > self.askCardView.frame.origin.x && adjustedPos.x < bottomRight.x && adjustedPos.y > self.askCardView.frame.origin.y && adjustedPos.y < bottomRight.y) {
        if (self.selectedPlayerUUID != nil && [self.game canAskForCard:cardView.card fromPlayer:self.selectedPlayerUUID]) {
            self.askCardImageView.image = cardView.image;
            self.recievedCards = @[cardView.card];
            self.askCardText.text = @"Waiting";
            self.putCard = YES;
            [self.game askForCard:cardView.card fromPlayer:self.selectedPlayerUUID];
            self.buttonSelected.backgroundColor = [UIColor clearColor];
            self.buttonSelected = nil;
            self.selectedPlayerUUID = nil;
            return YES;
        } else if (self.wantedRank != nil) {
            if (self.wantedRank != cardView.card.rank) {
                return NO;
            }
            
            [self.game.hand removeObject:cardView.card];
            [self.dataManager sendCard:cardView.card];
            if (![self.game hasAnyOfRank:self.wantedRank]) {
                self.wantedRank = nil;
                [self.dataManager sentLastCard];
                
                [self hideAsk];
                void (^setAlpha)() = ^void() {
                    self.wantedView.alpha = 0;
                };
                [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:setAlpha completion:nil];
            }
            
            return YES;
        }
    }
    
    return NO;
}

-(void)remakeCardPile {
    self.drawCard = [[CardView alloc] initOnView:self.view withCard:nil];
    [self.drawCard setClear:YES];
    [self.drawCard setUserInteractionEnabled:YES];
    [self.view bringSubviewToFront:self.drawCard];
    self.drawCard.delegate = self;
    self.drawCard.frame = self.drawPileImage.frame;
}

-(void)remakeAskPile {
    self.askCard = [[CardView alloc] initOnView:self.view withCard:nil];
    [self.askCard setClear:YES];
    [self.askCard setUserInteractionEnabled:YES];
    [self.view bringSubviewToFront:self.askCard];
    self.askCard.delegate = self;
    self.askCard.frame = self.askCardView.frame;
}

-(void)gotCards:(NSArray<Card *> *)cards {
    self.recievedCards = [cards arrayByAddingObjectsFromArray:self.recievedCards];
    self.recievedCardsIndex = 0;
    [self needsNewCard];
}

-(void)tellUserGoFish {
    self.askCardText.text = @"";
    NSLog(@"go fish, send message to user here please");
}

-(void)needsNewCard {
    [self remakeAskPile];
    
    self.askCardText.text = @"";
    
    if ([self.recievedCards count] == self.recievedCardsIndex) {
        [self.game recievedCards:self.recievedCards];
        if ([self.recievedCards count] == 1) {
            [self tellUserGoFish];
        }
        self.putCard = NO;
        self.askCardImageView.image = [UIImage imageNamed:@"blankcard.png"];
        [self hideAsk];
    } else {
        self.askCard.card = self.recievedCards[self.recievedCardsIndex];
        self.recievedCardsIndex++;
    }
}

-(void)touchMoved:(UITouch *)touch forCard:(CardView *)cardView {
    if (cardView == self.drawCard) {
        if ([self.game canFish]) {
            [self.dataManager sendFished];
            self.drawCard.card = [self.game fish];
            self.drawCard.shouldReturn = YES;
            [self.handView pickUpCard:self.drawCard referencePos:[touch locationInView:cardView]];
            [self remakeCardPile];
        }
    } else if (cardView == self.askCard) {
        if (self.askCard.card != nil) {
            self.askCard.shouldReturn = YES;
            [self.handView pickUpCard:self.askCard referencePos:[touch locationInView:cardView]];
            [self needsNewCard];
        }
    }
}

- (IBAction)showBooks {
    [self.recievedBooks removeAllObjects];
    [self.recievedNames removeAllObjects];
    
    for (NSString* playerUUID in self.game.playerUUIDs) {
        if (![playerUUID isEqualToString:self.game.meUUID]) {
            [self.dataManager playerBooks:playerUUID];
        }
    }
}

-(void)gotBooks:(NSArray<Card *> *)books forPlayer:(NSString *)playerUUID {
    [self.recievedBooks addObject:books];
    [self.recievedNames addObject:self.playerNames[playerUUID]];
    
    if ([self.recievedBooks count] == [self.game.playerUUIDs count] - 1) {
        [self performSegueWithIdentifier:@"books" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"books"]) {
        BooksViewController* controller = (BooksViewController*)segue.destinationViewController;
        controller.books = self.recievedBooks;
        controller.names = self.recievedNames;
    }
}

-(void)wasPressed:(CardView *)cardView {
    //stub
}

-(void)updateTurn {
    NSString* uuid = self.game.playerUUIDs[self.game.currentPlayer];
    if ([uuid isEqualToString:self.game.meUUID]) {
        self.turnLabel.text = @"Your Turn";
    } else {
        self.turnLabel.text = [[self.playerNames objectForKey:uuid] stringByAppendingString:@"'s Turn"];
    }
}

@end
