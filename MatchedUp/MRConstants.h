//
//  MRConstants.h
//  MatchedUp
//
//  Created by Mark Rabins on 8/11/14.
//  Copyright (c) 2014 edu.self.edu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRConstants : NSObject

// Global constants so that we will always use the properly formed string for our keys

#pragma mark - User Class

extern NSString *const kMRUserTagLineKey;

extern NSString *const kMRUserProfileKey;
extern NSString *const kMRUserProfileNameKey;
extern NSString *const kMRFirstNameKey;
extern NSString *const kMRLocationKey;
extern NSString *const kMRGenderKey;
extern NSString *const kMRBirthdayKey;
extern NSString *const kMRInterestedInKey;
extern NSString *const kMRUserProfilePictureURL;
extern NSString *const kMRUserProfileRelationshipStatusKey;
extern NSString *const kMRUserProfileAgeKey;

#pragma mark - Photo Class

extern NSString *const kMRPhotoClassKey;
extern NSString *const kMRPhotoUserKey;
extern NSString *const kMRPhotoPictureKey;

#pragma mark - Activity Class

extern NSString *const kMRActivityClassKey;
extern NSString *const kMRActivityTypeKey;
extern NSString *const kMRActivityFromUserKey;
extern NSString *const kMRActivityToUserKey;
extern NSString *const kMRActivityPhotoKey;
extern NSString *const kMRActivityTypeLikeKey;
extern NSString *const kMRActivityTypeDislikeKey;

#pragma mark - Settings

extern NSString *const kMRMenEnabledKey;
extern NSString *const kMRWomenEnabledkey;
extern NSString *const kMRSingleEnabledKey;
extern NSString *const kMRAgeMaxKey;

#pragma mark - ChatRoom

extern NSString *const kMRChatRoomClassKey;
extern NSString *const kMRChatRoomUser1Key;
extern NSString *const kMRChatRoomUser2Key;

#pragma mark - Chat

extern NSString *const kMRChatClassKey;
extern NSString *const kMRChatChatroomKey;
extern NSString *const kMRChatFromUserKey;
extern NSString *const kMRChatToUserKey;
extern NSString *const kMRChatTextKey;

@end
