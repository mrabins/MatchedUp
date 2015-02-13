//
//  MRHomeViewController.m
//  MatchedUp
//
//  Created by Mark Rabins on 8/12/14.
//  Copyright (c) 2014 edu.self.edu. All rights reserved.
//

#import "MRHomeViewController.h"
#import "MRTestUser.h"
#import "MRProfileViewController.h"
#import "MRMatchViewController.h"
#import "MRAnimator.h"

@interface MRHomeViewController () <MRMatchViewControllerDelegate, MRProfileViewControllerDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;
@property (strong, nonatomic) IBOutlet UIView *labelContainerView;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;


@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities;

@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL  isDislikedByCurrentUser;

@end

@implementation MRHomeViewController

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
    
    // [MRTestUser saveTestUserToParse];
    
    [self setupViews];

}

-(void)viewDidAppear:(BOOL)animated
{
    self.photoImageView.image = nil;
    self.firstNameLabel.text = nil;
    self.ageLabel.text = nil;
    
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kMRPhotoClassKey];
    [query whereKey:kMRPhotoUserKey notEqualTo:[PFUser currentUser]];
    [query includeKey:kMRPhotoUserKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error) {
             self.photos = objects;
             
             if ([self allowPhoto] == NO) {
                 [self setupNextPhoto];
             }
             else{
                 [self queryForCurrentPhotoIndex];
             }
         }
         else{
             NSLog(@"%@", error);
         }
             
     }];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    
    [self addShadowForView:self.buttonContainerView];
    [self addShadowForView:self.labelContainerView];
    self.photoImageView.layer.masksToBounds = YES;
}

-(void)addShadowForView:(UIView *)view
{
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = 4;
    view.layer.shadowRadius = 1;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 0.25;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"homeToProfileSegue"])
    {
        MRProfileViewController *profileVC =segue.destinationViewController;
        profileVC.photo = self.photo;
        profileVC.delegate = self;
    }
}


#pragma mark - IBActions

- (IBAction)likeButtonPressed:(UIButton *)sender
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Like"];
    
    [mixpanel flush];
    
    [self checkLike];
}

- (IBAction)dislikeButtonPressed:(id)sender
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Dislike"];
    
    [mixpanel flush];
    
    [self checkDislike];
}

- (IBAction)infoButtonPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
    
}
- (IBAction)chatBarButtonItem:(UIBarButtonItem *)sender
{

}
- (IBAction)settingsBarButtonPressed:(UIBarButtonItem *)sender
{

}

#pragma mark - Helper Methods

- (void)queryForCurrentPhotoIndex
{
    if ([self.photos count] >0) {
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[kMRPhotoPictureKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error){
                UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
                [self updateView];
            }
            else NSLog(@"%@", error);
        }];
        
        PFQuery *queryForLike = [PFQuery queryWithClassName:kMRActivityClassKey];
        [queryForLike whereKey:kMRActivityTypeKey equalTo:kMRActivityTypeLikeKey];
        [queryForLike whereKey:kMRActivityPhotoKey equalTo:self.photo];
        [queryForLike whereKey:kMRActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *queryForDislike = [PFQuery queryWithClassName:kMRActivityClassKey];
        [queryForDislike whereKey:kMRActivityTypeKey equalTo:kMRActivityTypeDislikeKey];
        [queryForDislike whereKey:kMRActivityPhotoKey equalTo:self.photo];
        [queryForDislike whereKey:kMRActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                self.activities = [objects mutableCopy];
                if ([self.activities count] == 0) {
                    self.isLikedByCurrentUser = NO;
                    self.isDislikedByCurrentUser = NO;
                    
                } else {
                    PFObject *activity = self.activities[0];
                    if ([activity[kMRActivityTypeKey] isEqualToString:kMRActivityTypeLikeKey]){
                        self.isLikedByCurrentUser = YES;
                        self.isDislikedByCurrentUser = NO;
                        
                    }
                    else if ([activity[kMRActivityTypeKey] isEqualToString:kMRActivityTypeDislikeKey]){
                        self.isLikedByCurrentUser = NO;
                    self.IsDislikedByCurrentUser = YES;
                        
                    }
                    else {
                        //Some other type of activity
                    }
                }
                self.likeButton.enabled = YES;
                self.dislikeButton.enabled = YES;
                self.infoButton.enabled = YES;
            }
        }];
    }
}
- (void)updateView
{
    self.firstNameLabel.text = self.photo[kMRPhotoUserKey][kMRUserProfileKey][kMRFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[kMRPhotoUserKey][kMRUserProfileKey][kMRUserProfileAgeKey]];
}

- (void)setupNextPhoto
{
    if (self.currentPhotoIndex +1 <self.photos.count)
    {
        self.currentPhotoIndex ++;
        if ([self allowPhoto] == NO){
            [self setupNextPhoto];
        }
        else{
            [self queryForCurrentPhotoIndex];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No More Users to View" message:@"Check back later to explore more profiles!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (BOOL)allowPhoto
{
    int maxAge = [[NSUserDefaults standardUserDefaults] integerForKey:kMRAgeMaxKey];
    BOOL men = [[NSUserDefaults standardUserDefaults] boolForKey:kMRMenEnabledKey];
    BOOL women = [[NSUserDefaults standardUserDefaults] boolForKey:kMRWomenEnabledkey];
    BOOL single = [[NSUserDefaults standardUserDefaults] boolForKey:kMRSingleEnabledKey];
    
    PFObject *photo = self.photos[self.currentPhotoIndex];
    PFUser *user = photo[kMRPhotoUserKey];
    
    int userAge = [user[kMRUserProfileKey][kMRUserProfileAgeKey]intValue];
    NSString *gender = user[kMRUserProfileKey][kMRGenderKey];
    NSString *relationshipStatus = user[kMRUserProfileKey][kMRUserProfileRelationshipStatusKey];
    
    if(userAge > maxAge){
        return NO;
    }
    else if (men == NO && [gender isEqualToString:@"male"]){
        return NO;
    }
    else if (women == NO && [gender isEqualToString:@"female"]){
        return NO;
    }
    else if (single == NO && ([relationshipStatus isEqualToString:@"single"] || relationshipStatus == nil)){
        return NO;
    }
    else{
        return YES;
    }
}

- (void)saveLike
{
    PFObject *likeActivity = [PFObject objectWithClassName:kMRActivityClassKey];
    [likeActivity setObject:kMRActivityTypeLikeKey forKey:kMRActivityTypeKey];
    [likeActivity setObject:[PFUser currentUser] forKey:kMRActivityFromUserKey];
    [likeActivity setObject:[self.photo objectForKey:kMRPhotoUserKey] forKey:kMRActivityToUserKey];
    [likeActivity setObject:self.photo forKey:kMRActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = YES;
        self.isDislikedByCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self checkForPhotoUserLikes];
        [self setupNextPhoto];
    }];
}

- (void)saveDislike
{
    PFObject *dislikeActivity = [PFObject objectWithClassName:kMRActivityClassKey];
    [dislikeActivity setObject:kMRActivityTypeDislikeKey forKey:kMRActivityTypeKey];
    [dislikeActivity setObject:[PFUser currentUser] forKey:kMRActivityFromUserKey];
    [dislikeActivity setObject:[self.photo objectForKey:kMRPhotoUserKey] forKey:kMRActivityToUserKey];
    [dislikeActivity setObject:self.photo forKey:kMRActivityPhotoKey];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = NO;
        self.isDislikedByCurrentUser = YES;
        [self.activities addObject:dislikeActivity];
        [self setupNextPhoto];
    }];
}

- (void)checkLike
{
    if (self.isLikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    }
    else if (self.isDislikedByCurrentUser){
        for (PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
    }
    else {
        [self saveLike];
    }
}

-(void)checkDislike
{
    if (self.isDislikedByCurrentUser){
        [self setupNextPhoto];
        return;
    }
    else if (self.isLikedByCurrentUser){
        for (PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    }
    else {
        [self saveDislike];
    }
}

- (void)checkForPhotoUserLikes
{
    PFQuery *query = [PFQuery queryWithClassName:kMRActivityClassKey];
    [query whereKey:kMRActivityFromUserKey equalTo:self.photo[kMRPhotoUserKey]];
    [query whereKey:kMRActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kMRActivityTypeKey equalTo:kMRActivityTypeLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] >0){
            [self createChatRoom];
        }
    }];
}

- (void)createChatRoom
{
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:kMRChatRoomClassKey];
    [queryForChatRoom whereKey:kMRChatRoomUser1Key equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:kMRChatRoomUser2Key equalTo:self.photo[kMRPhotoUserKey]];
    
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:kMRChatRoomClassKey];
    [queryForChatRoomInverse whereKey:kMRChatRoomUser1Key equalTo:self.photo];
    [queryForChatRoomInverse whereKey:kMRChatRoomUser2Key equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] == 0) {
            PFObject *chatroom = [PFObject objectWithClassName:kMRChatRoomClassKey];
            [chatroom setObject:[PFUser currentUser] forKey:kMRChatRoomUser1Key];
            [chatroom setObject:self.photo[kMRPhotoUserKey] forKey:kMRChatRoomUser2Key];
            [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                UIStoryboard *myStoryboard = self.storyboard;
                MRMatchViewController *matchViewController = [myStoryboard instantiateViewControllerWithIdentifier:@"matchVC"];
                matchViewController.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.75];
                matchViewController.transitioningDelegate = self;
                matchViewController.matchedUserImage = self.photoImageView.image;
                matchViewController.delegate = self;
                matchViewController.modalPresentationStyle = UIModalPresentationCustom;
                [self presentViewController:matchViewController animated:YES completion:nil];
            }];
        }
    }];
}

#pragma mark - MRMatchViewController Delegate

-(void)presentMatchesViewController
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
    }];
}


#pragma mark - MRProfileViewController Delegate

-(void)didPressLike
{
    [self.navigationController popViewControllerAnimated:NO];
    
    [self checkLike];
}

-(void)didPressDislike
{
    [self.navigationController popViewControllerAnimated:NO];
    
    [self checkDislike];
}

#pragma mark - UIViewController Transitioning Deletegate

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    MRAnimator *animator = [[MRAnimator alloc] init];
    animator.presenting = YES;
    return animator;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    MRAnimator *animator = [[MRAnimator alloc] init];
    return animator;
}







@end
