//
//  MREditProfileViewController.m
//  MatchedUp
//
//  Created by Mark Rabins on 8/12/14.
//  Copyright (c) 2014 edu.self.edu. All rights reserved.
//

#import "MREditProfileViewController.h"

@interface MREditProfileViewController () <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *tagLineTextView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;

@end

@implementation MREditProfileViewController

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
    
    self.tagLineTextView.delegate = self;
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    
    PFQuery *query = [PFQuery queryWithClassName:kMRPhotoClassKey];
    [query whereKey:kMRPhotoUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0){
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kMRPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.profilePictureImageView.image = [UIImage imageWithData:data];
            }];
        }
    }];
    self.tagLineTextView.text = [[PFUser currentUser] objectForKey:kMRUserTagLineKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextView Delegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]){
        [self.tagLineTextView resignFirstResponder];
        [[PFUser  currentUser] setObject:self.tagLineTextView.text forKey:kMRUserTagLineKey];
        [[PFUser currentUser] saveInBackground];
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    else {
        return YES;
    }
}


@end
