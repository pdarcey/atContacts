//
//  PDXConstants.h
//  @Contacts
//
//  Created by Paul Darcey on 19/09/2014.
//  © 2014 Paul Darcey. All rights reserved.
//

// Standard
static NSString * const kBlankString = @"";

// User defaults
static NSString * const kUserDefaultTwitterPreApprovalDialogHasBeenPresented = @"twitterPreApprovalDialogHasBeenPresented";
static NSString * const kUserDefaultUserDeniedPermissionToTwitter = @"userDeniedPermissionToTwitter";
static NSString * const kUserDefaultUserHasNoTwitterAccount = @"userHasNoAccount";
static NSString * const kUserDefaultLastUsedHashtag = @"lastUsedHashtag";
static NSString * const kUserDefaultTwitterAccount = @"defaultDefaultAccount";
static NSString * const kUserDefaultContactsPreApprovalDialogHasBeenPresented = @"contactsPreApprovalDialogHasBeenPresented";
static NSString * const kUserDefaultUserDeniedPermissionToContacts = @"userDeniedPermissionToContacts";

// Dictionary of person details
static NSString * const kPersonFirstName = @"firstName";
static NSString * const kPersonLastName = @"lastName";
static NSString * const kPersonTwitterName = @"twitterName";
static NSString * const kPersonEmailAddress = @"emailAddress";
static NSString * const kPersonPhoneNumber = @"phoneNumber";
static NSString * const kPersonWebAddress = @"webAddress";
static NSString * const kPersonTwitterDescription = @"twitterDescription";
static NSString * const kPersonPhotoURL = @"photoURL";
static NSString * const kPersonPhotoData = @"photoData";
static NSString * const kPersonFollowing = @"following";
static NSString * const kPersonIDString = @"idString";

@interface PDXConstants : NSObject

@end
