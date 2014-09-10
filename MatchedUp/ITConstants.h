//
//  ITConstants.h
//  MatchedUp
//
//  Created by yousheng chang on 9/1/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITConstants : NSObject

#pragma mark - User Class

extern NSString *const kITUserTagLineKey;

extern NSString *const kITUserProfileKey;
extern NSString *const kITUserProfileNameKey;
extern NSString *const kITUserProfileFirstNameKey;
extern NSString *const kITUserProfileLocationKey;
extern NSString *const kITUserProfileGenderkey;
extern NSString *const kITUserProfileBirthdayKey;
extern NSString *const kITUserProfileInterestedInKey;
extern NSString *const kITUserProfilePictureURL;
extern NSString *const kITUserProfileRelationshipStatusKey;
extern NSString *const kITUserProfileAgeKey;


#pragma mark - Photo Class

extern NSString *const kITPhotoClassKey;
extern NSString *const kITPhotoUserKey;
extern NSString *const kITPhotoPictureKey;

#pragma mark - Activity Class
extern NSString *const kITActivityClassKey;
extern NSString *const kITActivityTypeKey;
extern NSString *const kITActivityFromUserKey;
extern NSString *const kITActivityToUserKey;
extern NSString *const kITActivityPhotoKey;
extern NSString *const kITActivityTypeLikeKey;
extern NSString *const kITActivityTypeDislikeKey;

#pragma mark - Settings
extern NSString *const kITMenEnabledKey;
extern NSString *const kITWomenEnabledKey;
extern NSString *const kITSingleEnabledKey;
extern NSString *const kITAgeMaxKey;

#pragma mark - ChatRoom
extern NSString *const kITChatRoomClassKey;
extern NSString *const kITChatRoomUser1Key;
extern NSString *const kITChatRoomUser2Key;

#pragma mark - Chat
extern NSString *const kITChatClassKey;
extern NSString *const kITChatChatroomKey;
extern NSString *const kITChatFromUserKey;
extern NSString *const kITChatToUserKey;
extern NSString *const kITChatTextKey;



@end
