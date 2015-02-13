//
//  MRProfileViewController.m
//  MatchedUp
//
//  Created by Mark Rabins on 8/13/14.
//  Copyright (c) 2014 edu.self.edu. All rights reserved.
//

#import "MRProfileViewController.h"

@interface MRProfileViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;


@end

@implementation MRProfileViewController

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
    
    PFFile *pictureFile = self.photo[kMRPhotoPictureKey];
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.profilePictureImageView.image = [UIImage imageWithData:data];
    }];
    
    PFUser *user = self.photo[kMRPhotoUserKey];
    self.locationLabel.text = user[kMRUserProfileKey][kMRLocationKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", user[kMRUserProfileKey][kMRUserProfileAgeKey]];
    
    if (user[kMRUserProfileKey][kMRUserProfileRelationshipStatusKey] == nil){
        self.statusLabel.text = @"Single";
    }
    else {
        self.statusLabel.text = user[kMRUserProfileKey][kMRUserProfileRelationshipStatusKey];
    }
    
    self.tagLineLabel.text = user[kMRUserTagLineKey];
    
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    self.title = user [kMRUserProfileKey][kMRFirstNameKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)likeButtonPressed:(UIButton *)sender
{
    [self.delegate didPressLike];
}
- (IBAction)dislikeButtonPressed:(UIButton *)sender
{
    [self.delegate didPressDislike];
}








@end
