//
//  PDXNameFinder.m
//  atContacts
//
//  Created by Paul Darcey on 28/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXNameFinder.h"
#import "PreApprovalViewController.h"
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
    
    [self accountStore];
    [self accountType];
    _name = name;
    
    // Check if permission has previously been asked for
    if (![self dialogHasBeenPresented]) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *preApprovalViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PreApproval"];
        UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        [currentViewController presentViewController:preApprovalViewController animated:YES completion:nil ];
    }
    
    if (![self userDeniedPermission] && ![self userHasNoAccount]) {
        
        [self retrieveInformation];
        
    } else {
        // TODO Present a dialog saying we can't do anything without their permission
    }
}

/**
 *  Retrieves the information from Twitter and sends it to the parser
 *
 *
 *  @since 1.0
 */
- (void)retrieveInformation {
    // Actually access user's Twitter account to get info
    [_accountStore requestAccessToAccountsWithType:_twitterType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted == YES) {
            NSArray *arrayOfAccounts = [_accountStore accountsWithAccountType:_twitterType];
            
            if ([arrayOfAccounts count] > 0) {
                ACAccount *twitterAccount =
                [arrayOfAccounts lastObject];
                
                NSURL *requestURL = [NSURL URLWithString: @"https://api.twitter.com/1.1/users/lookup.json"];
                
                NSDictionary *parameters = @{@"screen_name" : _name};
                
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

/**
 *  Parses the results we get back from Twitter to extract Name, Photo, URL, Description
 *  Then calls the method to present the extracted information
 *
 *  @since 1.0
 */
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

#pragma mark - Convenience methods for setting Account Store, etc

/*
 *  Returns the account store.
 *  If the account doesn't already exist, it is created.
 */
- (ACAccountStore *)accountStore {
    
    if (_accountStore != nil) {
        return _accountStore;
    }
    ACAccountStore *account = [[ACAccountStore alloc] init];
    _accountStore = account;
    
    return _accountStore;
}

/*
 *  Returns the account store.
 *  If the account doesn't already exist, it is created.
 */
- (ACAccountType *)accountType {
    
    if (_twitterType != nil) {
        return _twitterType;
    }
    ACAccountType *accountType = [[self accountStore] accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    _twitterType = accountType;
    
    return _twitterType;
}



#pragma mark - Convenience methods for User Defaults

/**
 *  Convenience method to retrieve dialogHasBeenPresented from User Defaults
 *  Used to decide whether user has already been presented with pre-approval dialog
 *
 *  @return YES if the dialog has already been presented; NO if not
 *
 *  @since 1.0
 */
- (BOOL)dialogHasBeenPresented {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL dialogHasBeenPresented = [defaults boolForKey:@"dialogHasBeenPresented"];
    
    return dialogHasBeenPresented;
}

/**
 *  Convenience method to retrieve userDeniedPermission from User Defaults
 *  User has already been presented with pre-approval dialog
 *
 *  @return YES if the user has denied permission to use their stored Twitter credentials; NO if not
 *
 *  @since 1.0
 */
- (BOOL)userDeniedPermission {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL userDeniedPermission = [defaults boolForKey:@"userDeniedPermission"];
    
    return userDeniedPermission;
}

/**
 *  Convenience method to retrieve userHasNoAccount from User Defaults
 *  User has already been presented with pre-approval dialog
 *
 *  @return YES if the user has told us that they do not have a Twitter account; NO if not
 *
 *  @since 1.0
 */
- (BOOL)userHasNoAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL userHasNoAccount = [defaults boolForKey:@"userHasNoAccount"];
    
    return userHasNoAccount;
}

@end
