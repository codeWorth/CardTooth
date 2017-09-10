//
//  SearchViewController.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/20/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "SearchViewController.h"
#import "GinRummyGameViewController.h"
#import "LoadingView.h"
#import "DataManager.h"
#import "GoFishViewController.h"

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet LoadingView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) DataManager* dataManager;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [CBHostManager reset];
    [CBClientManager instance].delegate = self;
}

-(void)connected {
    [self performSelectorOnMainThread:@selector(connect) withObject:nil waitUntilDone:NO];
}

-(void)connect {
    self.statusLabel.text = @"Starting Game";
}

-(void)messageRecieved:(NSString *)message {
    [self performSelectorOnMainThread:@selector(handleMessage:) withObject:message waitUntilDone:NO];
}

-(void)handleMessage:(NSString*)message {
    if ([message isEqualToString:@"Gin Rummy"]) {
        [self performSegueWithIdentifier:@"client" sender:self];
    } else if ([message isEqualToString:@"Go Fish"]) {
        [self performSegueWithIdentifier:@"fishClient" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"client"]) {
        GinRummyGameViewController* controller = (GinRummyGameViewController*)segue.destinationViewController;
        controller.amHost = NO;
        [self.loadingView stop];
    } else if ([segue.identifier isEqualToString:@"fishClient"]) {
        GoFishViewController* controller = (GoFishViewController*)segue.destinationViewController;
        controller.amHost = NO;
        [self.loadingView stop];
    }
}

- (IBAction)stopSearching {
    [self.loadingView stop];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
