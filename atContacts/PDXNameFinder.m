//
//  PDXNameFinder.m
//  atContacts
//
//  Created by Paul Darcey on 28/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXNameFinder.h"
#import "PreApprovalViewController.h"
#import "ResultsViewController.h"

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
    
    // Check if permission has previously been asked for
    if (![self dialogHasBeenPresented]) {
        [self presentPreApprovalDialog];

    } else {
        
        [self retrieveInformation:name];
    }
}

/**
 *  Presents the pre-approval scene from the Main.storyboard
 *  User will select one of three options, which will determine what happens next:
 *  1. Use Twitter account - continues to retrieve information from Twitter
 *  2. I don't have a Twitter account - presents a dialog saying we need a Twitter account to
 *     use this app
 *  3. Do NOT use my Twitter account - presents a dialog saying we need a Twitter account to
 *     use this app
 *
 *  @since 1.0
 */
- (void)presentPreApprovalDialog {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PreApprovalViewController *preApprovalViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PreApproval"];
    preApprovalViewController.nameFinder = self;
    
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentViewController presentViewController:preApprovalViewController animated:YES completion:nil];
    });
}


- (void)retrieveInformation {
    [self retrieveInformation:_name];
}

/**
 *  Retrieves the information from Twitter and sends it to the parser
 *
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
 *  Parses the results we get back from Twitter to extract Name, Photo, URL, Description
 *  Then calls presentResults to present the extracted information
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

- (NSString *)parsePersonalURL:(NSDictionary *)data {
    NSArray *urls = [data valueForKey:@"url"];
    for (NSArray *item in urls) {
        NSArray *url = [item valueForKey:@"expanded_url"];
        if (url) {
            return url[0];
        }
    }
    
    return @"";
}

- (NSString *)extractString:(NSString *)key from:(NSDictionary *)data {
    NSArray *array = [data valueForKey:key];
    NSString *string = array[0];
    
    return string;
}

/**
 *  Retrieves the information from Twitter and sends it to the parser
 *
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

- (void)presentResults:(NSDictionary *)results {
    // Initialise Results screen
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ResultsViewController *resultsViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Results"];
    
    // Display view
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentViewController presentViewController:resultsViewController animated:YES completion:nil];
    });
}

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

- (PDXDataModel *)data {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    PDXDataModel *data = [appDelegate data];
    
    return data;
}


@end
