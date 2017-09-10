//
//  GameViewController.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/22/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "GinRummyGameViewController.h"
#import "CBHostManager.h"
#import "CBClientManager.h"
#import "GinRummyClient.h"
#import "CardHandView.h"
#import "Pile.h"
#import "DefaultCardHandView.h"

@interface GinRummyGameViewController ()

@property (weak, nonatomic) IBOutlet CardHandView *cardHand;
@property (weak, nonatomic) IBOutlet UIImageView *cardPile;
@property (nonatomic) CGRect cardRect;
@property (weak, nonatomic) IBOutlet UIImageView *discardPile;
@property (nonatomic) CGRect discardRect;
@property (weak, nonatomic) IBOutlet UIView *cardsView;
@property (weak, nonatomic) IBOutlet UIButton *beginButton;
@property (weak, nonatomic) IBOutlet UIButton *concedeButton;
@property (weak, nonatomic) IBOutlet UILabel *turnLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cardStackImage;

@property (nonatomic, strong) CardView* cardPileView;
@property (nonatomic, strong) CardView* discardPileView;
@property (nonatomic, strong) GinRummy* game;

@property (nonatomic, strong) DataManager* dataManager;

@end

@implementation GinRummyGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.amHost) {
        [CBHostManager instance].delegate = self;
    } else {
        [CBClientManager instance].delegate = self;
    }
    
    self.concedeButton.enabled = NO;
    
    self.discardPile.layer.cornerRadius = 5;
    self.cardHand.delegate = self;
    self.beginButton.enabled = NO;
    [self.view bringSubviewToFront:self.turnLabel];
    self.turnLabel.backgroundColor = [UIColor clearColor];
        
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber* imgNumber = (NSNumber*)[defaults objectForKey:@"cardback"];
    if (imgNumber != nil) {
        self.cardStackImage.image = [CardView cardBacks][imgNumber.integerValue];
    }
    
    if (self.amHost) {
        self.game = [[GinRummy alloc] initWithDelegate:self];
    } else {
        self.game = [[GinRummyClient alloc] initWithDelegate:self];
        [self.beginButton removeFromSuperview];
        self.beginButton = nil;
    }
    self.dataManager = [[DataManager alloc]initAsHost:self.amHost withGame:self.game];
    self.dataManager.delegate = self;
}

-(void)messageRecieved:(NSString *)message {
    [self performSelectorOnMainThread:@selector(processMessage:) withObject:message waitUntilDone:NO];
}

-(void)connected {
    [self performSelectorOnMainThread:@selector(enable) withObject:nil waitUntilDone:NO];
}

-(void)enable {
    if (self.amHost) {
        self.beginButton.enabled = YES;
        [self.dataManager sendGame:@"Gin Rummy"];
    }
    
    self.concedeButton.enabled = YES;
}

-(void)processMessage:(NSString*)message {
    [self.dataManager processRecievedMessage:message];
}

-(void)remakeCardPile {
    self.cardPileView = [[CardView alloc] initOnView:self.view withCard:nil];
    [self.cardPileView setClear:YES];
    [self.cardPileView setUserInteractionEnabled:YES];
    [self.view bringSubviewToFront:self.cardPileView];
    self.cardPileView.delegate = self;
    self.cardPileView.frame = self.cardRect;
}

-(void)remakeDiscardPile {
    self.discardPileView = [[CardView alloc] initOnView:self.view withCard:nil];
    [self.discardPileView setClear:YES];
    [self.discardPileView setUserInteractionEnabled:YES];
    [self.view bringSubviewToFront:self.discardPileView];
    self.discardPileView.delegate = self;
    self.discardPileView.frame = self.discardRect;
}

-(BOOL)cardView:(CardHandView *)view outsideReleased:(CardView *)cardView {
    CGPoint adjustedPos = CGPointMake(cardView.frame.origin.x + cardView.frame.size.width/2, cardView.frame.origin.y + cardView.frame.size.height/2);
    CGPoint bottomRight = CGPointMake(self.discardRect.origin.x + self.discardRect.size.width, self.discardRect.origin.y + self.discardRect.size.height);
    
    
    if (adjustedPos.x < self.discardRect.origin.x || adjustedPos.x > bottomRight.x || adjustedPos.y < self.discardRect.origin.y || adjustedPos.y > bottomRight.y) {
        return false;
    }
    
    if ([self.game canPutCardInDiscard:self.amHost]) {
        [self.dataManager sendPlaceCardOnDiscardPile:cardView.card];
        [self.game putCardInDiscard:cardView.card player:self.amHost];
        return YES;
    } else {
        return NO;
    }
}

-(void)player1Hand:(NSArray<Card *> *)cards {
    if (!self.amHost) {
        self.discardRect = CGRectMake(self.discardPile.frame.origin.x + self.cardsView.frame.origin.x, self.discardPile.frame.origin.y + self.cardsView.frame.origin.y, self.discardPile.frame.size.width, self.discardPile.frame.size.height);
        self.cardRect = CGRectMake(self.cardsView.frame.origin.x + self.cardPile.frame.origin.x, self.cardsView.frame.origin.y + self.cardPile.frame.origin.y, self.discardPile.frame.size.width, self.discardPile.frame.size.height);
        
        [self remakeCardPile];
        [self remakeDiscardPile];
    }
    
    [self.cardHand setDataSourceInitialObject:[[DefaultCardHandView alloc] initForFrame:self.cardHand.frame]];
    
    for (Card* card in cards) {
        [self.cardHand addCard:card];
    }
    
    [self connected];
}

-(void)player2Hand:(NSArray<Card *> *)cards {
    if (self.amHost) {
        [self.dataManager sendHand:cards];
        [self.dataManager sendDrawPile:self.game.cardDeck.cards];
        [self.dataManager sendStart:self.game.player1Turn];
    }
}

-(void)updateDiscard {
    Card* topDiscard = [self.game topDiscard];
    self.discardPile.image = [UIImage imageNamed:[topDiscard imageName]];
}

- (IBAction)dealCards:(UIButton *)sender {
    self.discardRect = CGRectMake(self.discardPile.frame.origin.x + self.cardsView.frame.origin.x, self.discardPile.frame.origin.y + self.cardsView.frame.origin.y, self.discardPile.frame.size.width, self.discardPile.frame.size.height);
    self.cardRect = CGRectMake(self.cardsView.frame.origin.x + self.cardPile.frame.origin.x, self.cardsView.frame.origin.y + self.cardPile.frame.origin.y, self.discardPile.frame.size.width, self.discardPile.frame.size.height);
    
    [self remakeCardPile];
    [self remakeDiscardPile];
    [self.game beginGame];
    [sender removeFromSuperview];
    self.beginButton = nil;
}

-(void)wasPressed:(CardView *)cardView {
}

-(void)touchMoved:(UITouch *)touch forCard:(CardView *)cardView {
    if (cardView == self.cardPileView) {
        if ([self.game canGetCardFromCards:self.amHost]) {
            [self.dataManager sendTookFromDrawPile];
            self.cardPileView.card = [self.game getCardFromCards:self.amHost];
            self.cardPileView.shouldReturn = YES;
            [self.cardHand pickUpCard:self.cardPileView referencePos:[touch locationInView:cardView]];
            [self remakeCardPile];
        }
    } else if (cardView == self.discardPileView) {
        if ([self.game canGetCardFromDiscard:self.amHost]) {
            [self.dataManager sendTookFromDiscardPile];
            self.discardPileView.card = [self.game getCardFromDiscards:self.amHost];
            self.discardPileView.shouldReturn = YES;
            [self.cardHand pickUpCard:self.discardPileView referencePos:[touch locationInView:cardView]];
            [self remakeDiscardPile];
        }
    }
}

-(void)updateTurn {
    if (self.game.player1Turn == self.amHost) {
        self.turnLabel.text = @"Your Turn";
        self.turnLabel.transform = CGAffineTransformScale(self.turnLabel.transform, 4, 4);
        [UIView animateWithDuration:0.4 delay:0.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.turnLabel.transform = CGAffineTransformScale(self.turnLabel.transform, 0.25, 0.25);
        } completion:nil];
    } else {
        if ([self.game didWin:[(DefaultCardHandView*)self.cardHand.activeDataSource getCards]]) {
            [self.dataManager sendVictory];
            [self performSegueWithIdentifier:@"win" sender:self];
        }
        self.turnLabel.text = @"Opponent Turn";
    }
    self.turnLabel.hidden = NO;
}

-(void)weWon {
    [self performSegueWithIdentifier:@"win" sender:self];
}

-(void)weLost {
    [self performSegueWithIdentifier:@"lose" sender:self];
}

- (IBAction)concede {
    [self.dataManager sendConcede];
    [self performSegueWithIdentifier:@"lose" sender:self];
}

@end


