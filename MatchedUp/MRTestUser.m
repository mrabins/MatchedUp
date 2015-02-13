//
//  MRTestUser.m
//  MatchedUp
//
//  Created by Mark Rabins on 8/15/14.
//  Copyright (c) 2014 edu.self.edu. All rights reserved.
//

#import "MRTestUser.h"

@implementation MRTestUser

+(void)saveTestUserToParse
{
    PFUser *newUser = [PFUser user];
    newUser.username = @"user1";
    newUser.password = @"password1";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error){
            NSDictionary *profile = @{kMRUserProfileAgeKey: @28, kMRBirthdayKey: @"08/14/1986", kMRFirstNameKey: @"Bonita", kMRGenderKey: @"female", kMRLocationKey: @"Tokyo, Japan", kMRUserProfileNameKey: @"Bonita Applebaum"};
            [newUser setObject:profile forKey:@"profile"];
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                UIImage *profileImage = [UIImage imageNamed:@"TestProfileImage.jpeg"];
                NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                
                PFFile *photoFile  = [PFFile fileWithData:imageData];
                [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded){
                        PFObject *photo = [PFObject objectWithClassName:kMRPhotoClassKey];
                        [photo setObject:newUser forKey:kMRPhotoUserKey];
                        [photo setObject:photoFile forKey:kMRPhotoPictureKey];
                        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            NSLog(@"photo saved successfullly");
                        }];
                    }
                }];
                
            }];
            
            
        }
     }];
}

@end
