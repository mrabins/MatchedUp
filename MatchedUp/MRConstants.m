//
//  MRConstants.m
//  MatchedUp/Users/markrabins/Desktop/UdemyiOSCourse/MatchedUp/MatchedUp.xcworkspace
//
//  Created by Mark Rabins on 8/11/14.
//  Copyright (c) 2014 edu.self.edu. All rights reserved.
//

#import "MRConstants.h"

@implementation MRConstants

#pragma mark - User Class

NSString *const  kMRUserTagLineKey                  = @"tagLine";

NSString *const kMRUserProfileKey                   = @"profile";
NSString *const kMRUserProfileNameKey               = @"name";
NSString *const kMRFirstNameKey                     = @"firstName";
NSString *const kMRLocationKey                      = @"location";
NSString *const kMRGenderKey                        = @"gender";
NSString *const kMRBirthdayKey                      = @"birthday";
NSString *const kMRInterestedInKey                  = @"interestedIn";
NSString *const kMRUserProfilePictureURL            = @"pictureURL";
NSString *const kMRUserProfileRelationshipStatusKey = @"relationshipStatus";
NSString *const kMRUserProfileAgeKey                = @"age";


#pragma mark - Photo Class

NSString *const kMRPhotoClassKey                    = @"Photo";
NSString *const kMRPhotoUserKey                     = @"user";
NSString *const kMRPhotoPictureKey                  = @"image";

NSString *const kMRActivityClassKey                 = @"Activity";
NSString *const kMRActivityTypeKey                  = @"type";
NSString *const kMRActivityFromUserKey              = @"fromUser";
NSString *const kMRActivityToUserKey                = @"toUser";
NSString *const kMRActivityPhotoKey                 = @"photo";
NSString *const kMRActivityTypeLikeKey              = @"like";
NSString *const kMRActivityTypeDislikeKey           = @"dislike";

#pragma mark - Settings

NSString *const kMRMenEnabledKey                   = @"men";
NSString *const kMRWomenEnabledkey                 = @"women";
NSString *const kMRSingleEnabledKey                = @"single";
NSString *const kMRAgeMaxKey                       = @"ageMax";

#pragma mark - ChatRoom

NSString *const kMRChatRoomClassKey                = @"ChatRoom";
NSString *const kMRChatRoomUser1Key                = @"user1";
NSString *const kMRChatRoomUser2Key                = @"user2";

#pragma mark - Chat

NSString *const kMRChatClassKey                     = @"Chat";
NSString *const kMRChatChatroomKey                  = @"chatroom";
NSString *const kMRChatFromUserKey                  = @"fromUser";
NSString *const kMRChatToUserKey                    = @"toUser";
NSString *const kMRChatTextKey                      = @"text";





@end
