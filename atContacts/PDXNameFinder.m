//
//  PDXNameFinder.m
//  atContacts
//
//  Created by Paul Darcey on 28/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXNameFinder.h"
@import Social;

@implementation PDXNameFinder

/**
 *  Checks if the user has authorised access to their Twitter account
 *  then gets info for name, if authorisation is ok
 *
 *  @param name Twitter user's name (not including the initial "@")
 *
 *  @since 1.0
 */
- (void)findName:(NSString *)name {
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    // Check if permission has previously been asked for
    
    
    // Actually access user's Twitter account to get info
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
         if (granted == YES) {
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
             
             if ([arrayOfAccounts count] > 0) {
                 ACAccount *twitterAccount =
                 [arrayOfAccounts lastObject];
                 
                 NSURL *requestURL = [NSURL URLWithString: @"https://api.twitter.com/1.1/users/lookup.json"];
                 
                 NSDictionary *parameters = @{@"screen_name" : name};
                 
                 SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestURL parameters:parameters];
                 
                 postRequest.account = twitterAccount;
                 
                 [postRequest performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                     if (responseData) {
                         NSInteger statusCode = urlResponse.statusCode;
                         if (statusCode >= 200 && statusCode < 300) {
                             _twitterData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                             
                             if (_twitterData != nil) {
                                 [self parseResults];
                             }
                         } else {
                             NSLog(@"[ERROR] Server responded: status code %ld %@", (long)statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
                         }
                     } else {
                         NSLog(@"[ERROR] An error occurred: %@", [error localizedDescription]);
                     }

                  }];
             }
         } else {
             // User has previously said they would give us permission to access their Twitter account
             // Check for error conditions
             NSLog(@"Error accessing user's Twitter account. Error: %@", error);
            //             typedef enum ACErrorCode {
            //                 ACErrorUnknown = 1,
            //                 ACErrorAccountMissingRequiredProperty,
            //                 ACErrorAccountAuthenticationFailed,
            //                 ACErrorAccountTypeInvalid,
            //                 ACErrorAccountAlreadyExists,
            //                 ACErrorAccountNotFound,
            //                 ACErrorPermissionDenied,
            //                 ACErrorAccessInfoInvalid,
            //                 ACErrorClientPermissionDenied
            //                 ACErrorAccessDeniedByProtectionPolicy
            //                 ACErrorCredentialNotFound
            //                 ACErrorFetchCredentialFailed,
            //                 ACErrorStoreCredentialFailed,
            //                 ACErrorRemoveCredentialFailed,
            //                 ACErrorUpdatingNonexistentAccount
            //                 ACErrorInvalidClientBundleID,
            //             } ACErrorCode;
             
         }
     }];
}

- (void)parseResults {
    // Extract the fields we want
    NSString *retrievedName = [_twitterData valueForKey:@"name"];
    
    // Break down name into components: first name, last name (= everything but first name), final name (final word in the string - used for search)
    NSArray *wordList = [retrievedName componentsSeparatedByString:@" "];
    NSString *retrievedFirstName = @"";
    NSString *retrievedLastName = @"";
    if ([wordList count] > 0) {
        retrievedFirstName = [wordList objectAtIndex:0];
        int i;
        for (i=1; i < [wordList count]; i++) {
            if (i>1) {
                retrievedLastName = [retrievedLastName stringByAppendingString:@" "];
            }
            retrievedLastName = [retrievedLastName stringByAppendingString:[wordList objectAtIndex:i]];
        }
    }
    NSString *retrievedFinalName = [wordList objectAtIndex:[wordList count]-1];
    NSString *retrievedPhotoURLString = [_twitterData valueForKey:@"profile_image_url"];
    NSString *retrievedPersonalURL = [_twitterData valueForKey:@"url"];
    NSString *retrievedDescription = [_twitterData valueForKey:@"description"];
    NSString *retrievedTwitterName = [NSString stringWithFormat:@"@%@", [_twitterData valueForKey:@"screen_name"]];

    NSString *output = [NSString stringWithFormat:@"\nTwitter Name = %@\nName = %@\nFirst Name = %@\nLast Name = %@\nFinal Name = %@\nDescription = %@\nURL = %@\nPicture URL = %@", retrievedTwitterName, retrievedName, retrievedFirstName, retrievedLastName, retrievedFinalName, retrievedDescription, retrievedPersonalURL, retrievedPhotoURLString];
    NSLog(@"%@",output);
    
    // Present results
}

@end
