//
//  SettingsViewController.m
//  CardTooth
//
//  Created by Andrew Cummings on 7/29/17.
//  Copyright © 2017 Andrew Cummings. All rights reserved.
//

#import "SettingsViewController.h"
#import "CardView.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *cardBackSegment;
@property (weak, nonatomic) IBOutlet UIImageView *cardView;

@end

#define MAX_LENGTH 10

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameField.delegate = self;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber* imgNumber = (NSNumber*)[defaults objectForKey:@"cardback"];
    if (imgNumber != nil) {
        self.cardView.image = [CardView cardBacks][imgNumber.integerValue];
        self.cardBackSegment.selectedSegmentIndex = imgNumber.integerValue;
    }
    
    NSString* name = [defaults objectForKey:@"name"];
    if (name == nil) {
        self.nameField.text = [[UIDevice currentDevice] name];
        if (self.nameField.text.length > MAX_LENGTH) {
            self.nameField.text = [self.nameField.text substringWithRange:NSMakeRange(0, MAX_LENGTH)];
        }
    } else {
        self.nameField.text = name;
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location + range.length > textField.text.length) {
        return NO;
    }
    
    NSInteger newLength = string.length + textField.text.length - range.length;
    return newLength <= MAX_LENGTH;
}

- (IBAction)saveSettings {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@(self.cardBackSegment.selectedSegmentIndex) forKey:@"cardback"];
    [defaults setObject:self.nameField.text forKey:@"name"];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelSettings {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)setImage:(UISegmentedControl *)sender {
    self.cardView.image = [CardView cardBacks][sender.selectedSegmentIndex];
}

@end
