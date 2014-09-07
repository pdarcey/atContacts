//
//  PDXNameFinder.m
//  atContacts
//
//  Created by Paul Darcey on 28/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXNameFinder.h"
#import "PDXPreApprovalViewController.h"
#import "PDXResultsViewController.h"

@implementation PDXNameFinder

#pragma mark - External interfaces
/**
 *  Checks if the user has authorised access to their Twitter account
 *  then gets info for name, if authorisation is ok
 *
 *  @param name Twitter user's name (not including the initial "@")
 *
 *  @since 1.0
 */
- (void)findName:(NSString *)name {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    [twitter getUserInfo:_name];
}

/**
 *  Allows pre-approval screens to call back saying to retrieve information, without needing to know the name of the person we're looking up
 *
 *  @since 1.0
 */
- (void)retrieveInformation {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    [twitter getUserInfo:_name];
}

#pragma mark - Twitter pre-approval

/**
 *  Presents the pre-approval scene from the Main.storyboard
 *
 *  User will select one of three options, which will determine what happens next:
 *
 *  1. Use Twitter account - continues to retrieve information from Twitter
 *
 *  2. I don't have a Twitter account - presents a dialog saying we need a Twitter account to
 *     use this app
 *
 *  3. Do NOT use my Twitter account - presents a dialog saying we need a Twitter account to
 *     use this app
 *
 *  @since 1.0
 */
- (void)presentPreApprovalDialog {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PDXPreApprovalViewController *preApprovalViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PreApproval"];
    preApprovalViewController.nameFinder = self;
    
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentViewController presentViewController:preApprovalViewController animated:YES completion:nil];
    });
}

#pragma mark - Get Twitter information

/**
 *  Retrieves information from Twitter for the user whose name is given
 *
 *  @param name A Twitter user name (i.e. @someone, without the leading "@")
 *
 *  @since 1.0
 */
- (void)retrieveInformation:(NSString *)name {
    if (![self userDeniedPermission] && ![self userHasNoAccount]) {
        
        // Actually access user's Twitter account to get info
        [_accountStore requestAccessToAccountsWithType:_twitterType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted == YES) {
                NSArray *arrayOfAccounts = [_accountStore accountsWithAccountType:_twitterType];
                
                if ([arrayOfAccounts count] > 0) {
                    ACAccount *twitterAccount =
                    [arrayOfAccounts lastObject];
                    
                    NSURL *requestURL = [NSURL URLWithString: @"https://api.twitter.com/1.1/users/lookup.json"];
                    
                    NSDictionary *parameters = @{@"screen_name" : name};
                    
                    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestURL parameters:parameters];
                    
                    request.account = twitterAccount;
                    
                    [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        if (responseData) {
                            NSInteger statusCode = urlResponse.statusCode;
                            if (statusCode >= 200 && statusCode < 300) {
                                NSDictionary *twitterData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                                
                                if (twitterData != nil) {
                                    // TODO Present dialog to user if results == nil
                                    [self parseLookupResults:twitterData];
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
    } else {
        // TODO Present a dialog saying we can't do anything without their permission
    }
}

/**
 *  Parses the results of a Twitter user lookup
 *
 *  @param twitterData A dictionary containing the results sent back from Twitter after being deserialized by NSJSONSerialization
 *
 *  @since 1.0
 */
- (void)parseLookupResults:(NSDictionary *)twitterData {
    // Extract the fields we want
    NSString *name = [self extractString:@"name" from:twitterData];
    NSString *idString = [self extractString:@"id_str" from:twitterData];
    NSString *photoURLString = [self extractString:@"profile_image_url" from:twitterData];
    NSString *description = [self extractString:@"description" from:twitterData];
    NSString *shortTwitterName = [self extractString:@"screen_name" from:twitterData];
    NSString *twitterName = [NSString stringWithFormat:@"@%@", shortTwitterName];
    NSString *personalURL = [self parsePersonalURL:twitterData];
    // TODO check that all the following paths exist, otherwise it will crash
//    NSArray *entityArray = [twitterData valueForKey:@"entities"];
//    NSArray *urlArray;
//    NSArray *urlsArray;
//    NSArray *personalURL;
//   if (entityArray[0]) {
//        urlArray = [entityArray valueForKey:@"url"];
//    }
//    if (!urlArray[0]) {
//        urlsArray = [urlArray valueForKey:@"urls"];
//    }
//    if (!urlsArray[0]) {
//        personalURL = [urlsArray valueForKey:@"expanded_url"];
//    }
//    if (!personalURL[0]) {
//        personalURL = @[ @[@""] ];
//    }

    NSDictionary *results = @{ @"name" : name, @"idString" :idString, @"photoURLString" : photoURLString, @"personalURL" : personalURL, @"description" : description, @"twitterName" : twitterName };
    
    [self saveResultsValues:results];
    // Present results
    [self presentResults:results];
}

/**
 *  The personal URL of a user (if it exists) is several layers within the dictionary. This method digs in and retrieves it (if it exists)
 *
 *  @param data  A dictionary containing the results sent back from Twitter after being deserialized by NSJSONSerialization
 *
 *  @return Non-shortened URL (i.e. http(s)://www.company.com, not http(s)://t.co/1uG4mhaB), or "" if it doesn't exist
 *
 *  @since 1.0
 */
- (NSString *)parsePersonalURL:(NSDictionary *)data {
        NSArray *entityArray = [data valueForKey:@"entities"];
        NSArray *urlArray;
        NSArray *urlsArray;
        NSArray *personalURL;
       if (entityArray[0]) {
            urlArray = [entityArray valueForKey:@"url"];
        }
        if (!urlArray[0]) {
            urlsArray = [urlArray valueForKey:@"urls"];
        }
        if (!urlsArray[0]) {
            personalURL = [urlsArray valueForKey:@"expanded_url"];
        }
        if (personalURL[0]) {
            NSString *url = personalURL[0];
            return url;
        }
    
    return @"";
}

/**
 *  Normally, extracting Twitter data from a dictionary of its returned data gives us an array. We want the actual string value
 *
 *  @param key  The key for the data we're looking for
 *  @param data Twitter data as a dictionary
 *
 *  @return String for the key
 *
 *  @since 1.0
 */
- (NSString *)extractString:(NSString *)key from:(NSDictionary *)data {
    NSArray *array = [data valueForKey:key];
    NSString *string = array[0];
    
    return string;
}

#pragma mark - Get follow status

/**
 *  Gets the follow status from Twitter. If User already follows the person, it saves YES to alreadyFollow in the data model
 *
 *  @param idString Twitter ID string (e.g. "1401881") of the person we want to check. This number comes from
 *                  the data we retrieved from Twitter earlier
 *
 *  @since 1.0
 */
- (void)getFollowStatus:(NSString *)idString {
    if (![self userDeniedPermission] && ![self userHasNoAccount]) {
        PDXDataModel __block *resultsData = [self data];
        // Actually access user's Twitter account to get info
        [_accountStore requestAccessToAccountsWithType:_twitterType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted == YES) {
                NSArray *arrayOfAccounts = [_accountStore accountsWithAccountType:_twitterType];
                
                if ([arrayOfAccounts count] > 0) {
                    ACAccount *twitterAccount =
                    [arrayOfAccounts lastObject];
                    
                    NSURL *requestURL = [NSURL URLWithString: @"https://api.twitter.com/1.1/friendships/lookup.json?"];
                    
                    NSDictionary *parameters = @{@"user_id" : idString};
                    
                    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestURL parameters:parameters];
                    
                    request.account = twitterAccount;
                    
                    [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        if (responseData) {
                            NSInteger statusCode = urlResponse.statusCode;
                            if (statusCode >= 200 && statusCode < 300) {
                                NSDictionary *followData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                                
                                if (followData != nil) {
                                    // TODO Present dialog to user if results == nil
                                   resultsData.alreadyFollow = [self parseFollowResults:followData];
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
    } else {
        // TODO Present a dialog saying we can't do anything without their permission
    }
}

/**
 *  Looks through Twitter data for connections to see if user is currently "following" the person
 *
 *  @param followData Twitter data in response to a "GET friendships/lookup" request
 *
 *  @return YES if user currently follows the person, NO if not (NO is default)
 *
 *  @since 1.0
 */
- (BOOL)parseFollowResults:(NSDictionary *)followData {
    NSArray *connections = [followData valueForKey:@"connections"];
    for (NSArray *item in connections) {
        for (NSString *connection in item) {
            if ([connection isEqualToString:@"following"]) {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - Results

/**
 *  Displays results
 *
 *  @param results Dictionary of results to display
 *
 *  @since 1.0
 */
- (void)presentResults:(NSDictionary *)results {
    // Initialise Results screen
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PDXResultsViewController *resultsViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Results"];
    
    // Display view
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentViewController presentViewController:resultsViewController animated:YES completion:nil];
    });
}

/**
 *  Saves results to data model. 
 *
 *  NOTE: Does not save the data model to disk!
 *
 *  @param results The information about the person that we are interested in (not all information Twitter has on the person)
 *
 *  @since 1.0
 */
- (void)saveResultsValues:(NSDictionary *)results {
    PDXDataModel *resultsData = [self data];
    // Split name into firstName / lastName
    NSString *name = [self fixNilValues:[results valueForKey:@"name"]];
    if (![name isEqualToString:@""]) {
        NSArray *nameArray = [name componentsSeparatedByString:@" "];
        NSString *firstWord = nameArray[0];
        if ([name isEqualToString:firstWord]) {
            // Name is just one word
            resultsData.firstName = name;
            resultsData.lastName = @"";
        } else {
            // Name is multi-word
            resultsData.firstName = firstWord;
            resultsData.lastName = [name substringFromIndex:[firstWord length]+1]; // The +1 is to remove the leading space (" ")
        }
    }
    resultsData.idString = [self fixNilValues:[results valueForKey:@"idString"]];
    resultsData.photoURL = [self fixNilValues:[results valueForKey:@"photoURLString"]];
    resultsData.twitterName = [self fixNilValues:[results valueForKey:@"twitterName"]];
    resultsData.emailAddress = [self fixNilValues:[results valueForKey:@"email"]];
    resultsData.phoneNumber = [self fixNilValues:[results valueForKey:@"phone"]];
    resultsData.wwwAddress = [self fixNilValues:[results valueForKey:@"personalURL"]];
    resultsData.twitterDescription = [self fixNilValues:[results valueForKey:@"description"]];
}

/**
 *  Changes string values of nil to @""
 *
 *  @param string Any string value
 *
 *  @return Either the original string (if it is not nil) or @""
 *
 *  @since 1.0
 */
- (NSString *)fixNilValues:(NSString *)string {
    if (string) {
        return string;
    } else {
        return @"";
    }
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
 *
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
 *
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
 *
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

/**
 *  Convenience method to retrieve data model from User Defaults
 *
 *  @return Data model stored in User Defaults
 *
 *  @since 1.0
 */
- (PDXDataModel *)data {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    PDXDataModel *data = [appDelegate data];
    
    return data;
}


@end
