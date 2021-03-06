//
//  PDXTwitterCommunicator+TestExtensions.h
//  atContacts
//
//  Created by Paul Darcey on 11/09/2014.
//  © 2014 Paul Darcey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDXTwitterCommunicator (TestExtensions)

/**
 *  Exposes methods within PDXTwitterCommunicator which would otherwise not be available for individual testing
 *
 *  The following are only exposed for testing
 *
 *  @since 1.0
 */

- (NSDictionary *)parseUsersLookup:(NSDictionary *)data;
- (NSDictionary *)splitName:(NSString *)name;
- (BOOL)parseFriendshipsCreate:(NSDictionary *)data;
- (BOOL)parseFriendshipsLookup:(NSDictionary *)data;
- (NSString *)parsePersonalURL:(NSDictionary *)data;
- (NSString *)extractString:(NSString *)key from:(NSDictionary *)data;
- (ACAccountStore *)accountStore;
- (ACAccountType *)accountType;
- (BOOL)dialogHasBeenPresented;
- (BOOL)userDeniedPermission;
- (BOOL)userHasNoAccount;
- (NSString *)identifier;
- (void)setDefaultTwitterAccount:(NSString *)identifier;
- (ACAccount *)defaultTwitterAccount;
- (ACAccount *)twitterAccountWithIdentifier:(NSString *)identifier;
- (NSArray *)arrayOfAccountIdentifiers:(NSArray *)arrayOfAccounts;
- (ACAccount *)askForDefaultTwitterAccount:(NSArray *)arrayOfAccountIdentifiers;

@end
