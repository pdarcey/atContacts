//
//  PDXTwitterCommunicator.h
//  atContacts
//
//  Created by Paul Darcey on 7/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDXDataModel.h"
@import Accounts;
@import Social;

@interface PDXTwitterCommunicator : NSObject

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccountType *twitterType;

- (void)getUserInfo:(NSString *)twitterName;
- (void)getFollowStatus:(NSString *)idString;
- (void)follow:(NSString *)idString;
- (void)unfollow:(NSString *)idString;

typedef NS_ENUM(NSInteger, PDXRequestType) {
    PDXRequestTypeGetUserInfo,
    PDXRequestTypeGetFollowStatus,
    PDXRequestTypeFollow,
    PDXRequestTypeUnfollow
};

@end

@protocol PDXTwitterCommunicatorDelegate
#pragma mark - Protocol

@optional
- (void)toggleTwitter:(BOOL)onOff;
- (void)displayInfo:(NSDictionary *)data;

@end

