//
//  PDXTwitterCommunicator.h
//  atContacts
//
//  Created by Paul Darcey on 7/09/2014.
//  © 2014 Paul Darcey. All rights reserved.
//

@import Foundation;
@import Accounts;
@import Social;
#import "PDXConstants.h"

#pragma mark - Protocol

@protocol PDXTwitterCommunicatorDelegate <NSObject>

@required

- (void)displayErrorMessage:(NSString *)message;
- (void)displayAlert:(UIAlertController *)alert;

@optional
- (void)followedOnTwitter:(BOOL)success;
- (void)displayInfo:(NSDictionary *)data;
- (void)displayUserImage:(UIImage *)image;

@end

# pragma mark - Constants

// Twitter API URLs
static NSString * const kTwitterAPIURLUsersLookup = @"https://api.twitter.com/1.1/users/lookup.json";
static NSString * const kTwitterAPIURLFriendshipsLookup = @"https://api.twitter.com/1.1/friendships/lookup.json?";
static NSString * const kTwitterAPIURLFriendshipsCreate = @"https://api.twitter.com/1.1/friendships/create.json";

// Twitter API Parameter Names
static NSString * const kTwitterParameterName = @"name";
static NSString * const kTwitterParameterIDStr = @"id_str";
static NSString * const kTwitterParameterProfileImageUrl = @"profile_image_url";
static NSString * const kTwitterParameterDescription = @"description";
static NSString * const kTwitterParameterScreenName = @"screen_name";
static NSString * const kTwitterParameterURL = @"url";
static NSString * const kTwitterParameterFollowing = @"following";
static NSString * const kTwitterParameterConnections = @"connections";
static NSString * const kTwitterParameterEntities = @"entities";
static NSString * const kTwitterParameterURLS = @"urls";
static NSString * const kTwitterParameterExpandedURL = @"expanded_url";
static NSString * const kTwitterParameterUserID = @"user_id";
static NSString * const kTwitterParameterFollow = @"follow";
static NSString * const kTwitterParameterTrue = @"true";
static NSString * const kTwitterParameterFalse = @"false";

// User Defaults Names
static NSString * const kUserDefaultTwitterApproved = @"twitterApproved";
static NSString * const kUserDefaultTwitterPreApprovalPresented = @"twitterPreApprovalPresented";
static NSString * const kUserDefaultTwitterDenied = @"twitterDenied";
static NSString * const kUserDefaultTwitterNoTwitterAccount = @"twitterNoAccount";

// Alerts
static NSString * const kAlertTitle = @"Problem";

# pragma mark - Interface

@interface PDXTwitterCommunicator : NSObject

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccountType *twitterType;
@property (weak, nonatomic) id < PDXTwitterCommunicatorDelegate > delegate;
@property (strong, nonatomic) NSString *twitterName;

- (void)getUserInfo:(NSString *)twitterName;
- (void)getUserImage:(NSString *)idString;
- (void)getFollowStatus:(NSString *)idString;
- (void)follow:(NSString *)idString;
- (void)unfollow:(NSString *)idString;

typedef NS_ENUM(NSInteger, PDXRequestType) {
    PDXRequestTypeGetUserInfo,
    PDXRequestTypeGetFollowStatus,
    PDXRequestTypeFollow,
    PDXRequestTypeUnfollow
};

typedef NS_ENUM(NSInteger, PDXTwitterAlert) {
    PDXTwitterAlertInitialDialog,
    PDXTwitterAlertNoTwitterDialog,
    PDXTwitterAlertDeniedDialog,
    PDXTwitterAlertSetUpTwitterDialog,
    PDXTwitterAlertAllowAccessDialog,
    PDXTwitterAlertAuthenticationFailed,
    PDXTwitterAlertAccountNotFound,
    PDXTwitterAlertPermissionDenied,
    PDXTwitterAlertDeniedByProtectionPolicy,
    PDXTwitterAlertNonExistingAccount
};

@end
