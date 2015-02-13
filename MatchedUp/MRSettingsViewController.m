//
//  MRSettingsViewController.m
//  MatchedUp
//
//  Created by Mark Rabins on 8/12/14.
//  Copyright (c) 2014 edu.self.edu. All rights reserved.
//

#import "MRSettingsViewController.h"

@interface MRSettingsViewController ()

@property (strong, nonatomic) IBOutlet UISlider *ageSlider;
@property (strong, nonatomic) IBOutlet UISwitch *menSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *womenSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *singleSwitch;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UIButton *editProfileButton;

@end

@implementation MRSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ageSlider.value = [[NSUserDefaults standardUserDefaults] integerForKey:kMRAgeMaxKey];
    self.menSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kMRMenEnabledKey];
    self.womenSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kMRWomenEnabledkey];
    self.singleSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kMRSingleEnabledKey];
    
    [self.ageSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.menSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.womenSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.singleSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)logoutButtonPressed:(UIButton *)sender
{
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)editProfileButtonPressed:(UIButton *)sender
{

}

#pragma mark - Helper

- (void)valueChanged:(id)sender
{
    if (sender == self.ageSlider){
        [[NSUserDefaults standardUserDefaults] setInteger:(int)self.ageSlider.value forKey:kMRAgeMaxKey];
        self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
    }
    else if (sender == self.menSwitch){
        [[NSUserDefaults standardUserDefaults] setBool:self.menSwitch.isOn forKey:kMRMenEnabledKey];
    }
    else if (sender == self.womenSwitch){
        [[NSUserDefaults standardUserDefaults] setBool:self.womenSwitch.isOn forKey:kMRWomenEnabledkey];
    }
    else if (sender == self.singleSwitch){
        [[NSUserDefaults standardUserDefaults] setBool:self.singleSwitch.isOn forKey:kMRSingleEnabledKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
