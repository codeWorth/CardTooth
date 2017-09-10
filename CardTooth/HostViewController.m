//
//  HostViewController.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/20/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "HostViewController.h"
#import "CBHostManager.h"
#import "PeripheralCell.h"
#import "GinRummyGameViewController.h"
#import "GoFishViewController.h"

@interface HostViewController ()

@property (weak, nonatomic) IBOutlet UIRefreshControl *refresh;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (nonatomic, strong) NSMutableArray* selectedPlayers;
@property (nonatomic) NSInteger minPlayers;
@property (nonatomic) NSInteger maxPlayers;

@end

@implementation HostViewController

- (IBAction)refresh:(UIRefreshControl *)sender {
    [[CBHostManager instance] clear];
    [self.tableView reloadData];
    [sender endRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [CBHostManager reset];
    [CBHostManager instance].tableView = self.tableView;
    
    
    self.selectedPlayers = [NSMutableArray array];
    self.startButton.enabled = NO;
    if ([self.game isEqualToString:@"Gin Rummy"]) {
        self.minPlayers = 1;
        self.maxPlayers = 1;
    } else if ([self.game isEqualToString:@"Go Fish"]) {
        self.minPlayers = 1;
        self.maxPlayers = 4;
    }
    
    
    self.refresh.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:220.0/255.0 alpha:1];
    self.refresh.tintColor = [UIColor whiteColor];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Forever Lost.png"]];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[CBHostManager instance].peripherals count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PeripheralData* data = [[CBHostManager instance].peripherals objectAtIndex:indexPath.row];
    
    PeripheralCell* cell = [tableView dequeueReusableCellWithIdentifier:[PeripheralCell ri]];
    [cell setCellData:data];
    [cell setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2f]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PeripheralCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.selectedPlayers containsObject:cell]) {
        [self.selectedPlayers removeObject:cell];
        [cell hideCheckmark];
        [self updateStartButton];
    } else {
        [self.selectedPlayers addObject:cell];
        [cell showCheckmark];
        [self updateStartButton];
    }
}

-(void)updateStartButton {
    if ([self.selectedPlayers count] < self.minPlayers) {
        self.startButton.enabled = NO;
    } else if ([self.selectedPlayers count] > self.maxPlayers) {
        self.startButton.enabled = NO;
    } else {
        self.startButton.enabled = YES;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"connect"]) {
        GinRummyGameViewController* controller = (GinRummyGameViewController*)segue.destinationViewController;
        controller.amHost = YES;
    } else if ([segue.identifier isEqualToString:@"fishHost"]) {
        GoFishViewController* controller = (GoFishViewController*)segue.destinationViewController;
        controller.amHost = YES;
        
        NSMutableArray* peers = [NSMutableArray array];
        for (PeripheralCell* cell in self.selectedPlayers) {
            [peers addObject:cell.data];
        }
        controller.peers = peers;
    }
}

- (IBAction)closeLobby {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)start {
    for (PeripheralCell* cell in self.selectedPlayers) {
        [[CBHostManager instance] connectTo:cell.data.peripheral];
    }
    
    if ([self.game isEqualToString:@"Gin Rummy"]) {
        [self performSegueWithIdentifier:@"connect" sender:self];
    } else if ([self.game isEqualToString:@"Go Fish"]) {
        [self performSegueWithIdentifier:@"fishHost" sender:self];
    }
}

@end
