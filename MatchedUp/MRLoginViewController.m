//
//  MRLoginViewController.m
//  MatchedUp
//
//  Created by Mark Rabins on 8/7/14.
//  Copyright (c) 2014 edu.self.edu. All rights reserved.
//

#import "MRLoginViewController.h"

@interface MRLoginViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableData *imageData;


@end

@implementation MRLoginViewController

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
    self.activityIndicator.hidden= YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        [self UpdateUserInformation];
        [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)loginButtonPressed:(UIButton *)sender
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    NSArray *permissionsArray = @[@"user_about_me", @"user_interests", @"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [self.activityIndicator startAnimating];
        self.activityIndicator.hidden = YES;
        if (!user){
            if (!error){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"The Facebook Login was Canceled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];
            }
        }
        else{
            [self UpdateUserInformation];
            [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
        }
    }];
}

#pragma mark - Helper Method

-(void) UpdateUserInformation
{
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if (!error){
            NSDictionary *userDictionary = (NSDictionary *) result;
            
            //create URL
            NSString *facebookID = userDictionary[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];
            
            if (userDictionary[@"name"]){
                userProfile[kMRUserProfileNameKey] = userDictionary[@"name"];
            }
            if (userDictionary[@"first_name"]){
                userProfile[kMRFirstNameKey] = userDictionary[@"first_name"];
            }
            if (userDictionary[@"location"][@"name"]){
                userProfile[kMRLocationKey] = userDictionary[@"location"][@"name"];
            }
            if (userDictionary[@"gender"]){
                userProfile[kMRGenderKey] = userDictionary[@"gender"];
            }
            if (userDictionary [@"birthday"]){
                userProfile[kMRBirthdayKey] = userDictionary[@"birthday"];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                NSDate *date = [formatter dateFromString:userDictionary[@"birthday"]];
                NSDate *now = [NSDate date];
                NSTimeInterval seconds = [now timeIntervalSinceDate:date];
                int age = seconds / 31536000;
                userProfile[kMRUserProfileAgeKey] = @(age);
            }
            if (userDictionary[@"interested_in"]){
                userProfile[kMRInterestedInKey] = userDictionary [@"interested_in"];
            }
            if (userDictionary[@"relationship_status"]){
                userProfile[kMRUserProfileRelationshipStatusKey] = userDictionary [@"relationship_status"];
            }
            if ([pictureURL absoluteString]){
                userProfile[kMRUserProfilePictureURL] = [pictureURL absoluteString];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:kMRUserProfileKey];
            [[PFUser currentUser] saveInBackground];
            
            [self requestImage];
        }
        else{
            NSLog(@"Error in FB request %@", error);
        }
        
    }];
}

-(void)uploadPFFileToParse:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    
    if(!imageData){
        NSLog(@"imageData was not found");
        return;
    }
    
    PFFile *photoFile = [PFFile fileWithData:imageData];
    
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            // Create a PFObject of class Photo. Set the current user for its' user key and set the PFFile for its image key

            PFObject *photo = [PFObject objectWithClassName:kMRPhotoClassKey];
            [photo setObject:[PFUser currentUser] forKey:kMRPhotoUserKey];
            [photo setObject:photoFile forKey:kMRPhotoPictureKey];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Photo saved successfully");
            }];
        }
    }];
    
    
}

-(void)requestImage
{
    PFQuery *query = [PFQuery queryWithClassName:kMRPhotoClassKey];
    [query whereKey:kMRPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number ==0)
        {
            PFUser *user  = [PFUser currentUser];
            self.imageData = [[NSMutableData alloc] init];
            
            NSURL *profilePictureURL = [NSURL URLWithString:user [kMRUserProfileKey] [kMRUserProfilePictureURL]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (!urlConnection){
                NSLog(@"Failed to Download Picture");
            }
        
        }
    }];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profileImage];
}



@end
