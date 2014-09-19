//
//  PDXConstants.h
//  @Contacts
//
//  Created by Paul Darcey on 19/09/2014.
//  Copyright © 2014 Paul Darcey. All rights reserved.
//

// Standard
static NSString * const kBlankString = @"";

// User defaults
static NSString * const kUserDefaultDialogHasBeenPresented = @"dialogHasBeenPresented";
static NSString * const kUserDefaultUserDeniedPermission = @"userDeniedPermission";
static NSString * const kUserDefaultUserHasNoAccount = @"userHasNoAccount";
static NSString * const kUserDefaultLastUsedHashtag = @"lastUsedHashtag";
static NSString * const kUserDefaultDefaultAccount = @"defaultDefaultAccount";

// Dictionary of person details
static NSString * const kPersonFirstName = @"firstName";
static NSString * const kPersonLastName = @"lastName";
static NSString * const kPersonTwitterName = @"twitterName";
static NSString * const kPersonEmailAddress = @"emailAddress";
static NSString * const kPersonPhoneNumber = @"phoneNumber";
static NSString * const kPersonWwwAddress = @"wwwAddress";
static NSString * const kPersonTwitterDescription = @"twitterDescription";
static NSString * const kPersonPhotoURL = @"photoURL";
static NSString * const kPersonPhotoData = @"photoData";
static NSString * const kPersonFollowing = @"following";
static NSString * const kPersonIdString = @"idString";

@interface PDXConstants : NSObject

@end
