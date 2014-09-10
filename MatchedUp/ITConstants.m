//
//  ITConstants.m
//  MatchedUp
//
//  Created by yousheng chang on 9/1/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import "ITConstants.h"

@implementation ITConstants

NSString *const kITUserTagLineKey                   = @"tagLine";

NSString *const kITUserProfileKey                   = @"profile";
NSString *const kITUserProfileNameKey               = @"name";
NSString *const kITUserProfileFirstNameKey          = @"firstName";
NSString *const kITUserProfileLocationKey           = @"location";
NSString *const kITUserProfileGenderkey             = @"gender";
NSString *const kITUserProfileBirthdayKey           = @"birthday";
NSString *const kITUserProfileInterestedInKey       = @"interestedIn";
NSString *const kITUserProfilePictureURL            = @"pictureURL";
NSString *const kITUserProfileRelationshipStatusKey = @"relationshipStatus";
NSString *const kITUserProfileAgeKey                = @"age";

#pragma mark - Photo Class
NSString *const kITPhotoClassKey        = @"Photo";
NSString *const kITPhotoUserKey         = @"user";
NSString *const kITPhotoPictureKey      = @"image";

#pragma mark - Activity Class
NSString *const kITActivityClassKey     = @"Activity";
NSString *const kITActivityTypeKey      = @"type";
NSString *const kITActivityFromUserKey  = @"fromUser";
NSString *const kITActivityToUserKey    = @"toUser";
NSString *const kITActivityPhotoKey     = @"photo";
NSString *const kITActivityTypeLikeKey  = @"like";
NSString *const kITActivityTypeDislikeKey = @"dislike";

#pragma mark - Settings
NSString *const kITMenEnabledKey        =   @"men";
NSString *const kITWomenEnabledKey      =   @"women";
NSString *const kITSingleEnabledKey     =   @"single";
NSString *const kITAgeMaxKey            =   @"ageMax";

#pragma mark - ChatRoom
NSString *const kITChatRoomClassKey     = @"ChatRoom";
NSString *const kITChatRoomUser1Key     = @"user1";
NSString *const kITChatRoomUser2Key     = @"user2";

#pragma mark - Chat
NSString *const kITChatClassKey         = @"Chat";
NSString *const kITChatChatroomKey      = @"chatroom";
NSString *const kITChatFromUserKey      = @"fromUser";
NSString *const kITChatToUserKey        = @"toUser";
NSString *const kITChatTextKey          = @"text";

@end
