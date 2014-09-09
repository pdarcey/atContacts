//
//  PDXTwitterCommunicator.m
//  atContacts
//
//  Created by Paul Darcey on 7/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXTwitterCommunicator.h"
#import "AppDelegate.h"

@implementation PDXTwitterCommunicator

#pragma mark - Generic request

/**
 *  Sends a request to Twitter's APIs using the user's Twitter credentials stored in Settings
 *
 *  @param url         Twitter API URL
 *  @param getOrPost   GET or POST type API
 *  @param parameters  Dictionary of additional parameters for the API (e.g. {@"screen_name" : @"twittername"})
 *  @param requestType PDXRequestType (see specific requests below)
 *
 *  @since 1.0
 */
- (void)sendTwitterRequestTo:(NSURL *)url getOrPost:(SLRequestMethod)getOrPost parameters:(NSDictionary *)parameters requestType:(PDXRequestType)requestType {
    ACAccountStore *store = [self accountStore];
    ACAccountType *accountType = [self accountType];
    if (![self userDeniedPermission] && ![self userHasNoAccount]) {
        // Actually access user's Twitter account to get info
        [store requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted == YES) {
                NSArray *arrayOfAccounts = [store accountsWithAccountType:accountType];
                
                if ([arrayOfAccounts count] > 0) {
                    ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                    
                    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:getOrPost URL:url parameters:parameters];
                    
                    request.account = twitterAccount;
                    
                    NSDictionary __block *dataDictionary;
                    [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        if (responseData) {
                            NSInteger statusCode = urlResponse.statusCode;
                            if (statusCode >= 200 && statusCode < 300) {
                                dataDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                                
                                if (dataDictionary != nil) {
                                    [self handleResponse:dataDictionary requestType:requestType];
                                    
                                } else {
                                    [self resultsDataEqualsNil:error];
                                }
                            } else {
                                [self performRequestWithHandlerError:urlResponse];
                            }
                        } else {
                            [self resultsDataEqualsNil:error];
                        }
                        
                    }];
                }
            } else {
                [self requestAccessToAccountsError:error];
                
            }
        }];
    } else {
        // TODO Present a dialog saying we can't do anything without their permission
    }
}

#pragma mark - Specific requests
/**
 *  Get user infor for twitterName
 *
 *  @param twitterName Twitter name to look up. Does NOT include the leading "@" symbol
 *
 *  @since 1.0
 */
- (void)getUserInfo:(NSString *)twitterName {
    NSURL *url = [NSURL URLWithString: @"https://api.twitter.com/1.1/users/lookup.json"];
    NSDictionary *parameters = @{@"screen_name" : twitterName};
    SLRequestMethod get = SLRequestMethodGET;
    
    [self sendTwitterRequestTo:url getOrPost:get parameters:parameters requestType:PDXRequestTypeGetUserInfo];

}

/**
 *  Does the user currently follow the Twitter user with the ID idString?
 *
 *  @param idString Twitter's unique ID string for users. Obtained from the getUserInfo query
 *
 *  @since 1.0
 */
- (void)getFollowStatus:(NSString *)idString {
    NSURL *url = [NSURL URLWithString: @"https://api.twitter.com/1.1/friendships/lookup.json?"];
    NSDictionary *parameters = @{@"user_id" : idString};
    SLRequestMethod get = SLRequestMethodGET;
    
    [self sendTwitterRequestTo:url getOrPost:get parameters:parameters requestType:PDXRequestTypeGetFollowStatus];
    
}

/**
 *  Sets the user's Twitter account to follow the Twitter user with the ID idString
 *
 *  @param idString Twitter's unique ID string for users. Obtained from the getUserInfo query
 *
 *  @since 1.0
 */
- (void)follow:(NSString *)idString {
    NSURL *url = [NSURL URLWithString: @"https://api.twitter.com/1.1/friendships/create.json"];
    NSDictionary *parameters = @{@"user_id" : idString, @"follow" : @"true"};
    SLRequestMethod post = SLRequestMethodPOST;
    
    [self sendTwitterRequestTo:url getOrPost:post parameters:parameters requestType:PDXRequestTypeFollow];
    
}

/**
 *  Sets the user's Twitter account to NOT follow the Twitter user with the ID idString
 *
 *  @param idString Twitter's unique ID string for users. Obtained from the getUserInfo query
 *
 *  @since 1.0
 */
- (void)unfollow:(NSString *)idString {
    NSURL *url = [NSURL URLWithString: @"https://api.twitter.com/1.1/friendships/create.json"];
    NSDictionary *parameters = @{@"user_id" : idString, @"follow" : @"false"};
    SLRequestMethod post = SLRequestMethodPOST;
    
    [self sendTwitterRequestTo:url getOrPost:post parameters:parameters requestType:PDXRequestTypeUnfollow];
    
}

#pragma mark - Handle Responses

/**
 *  Chooses how to handle the response from a Twitter request
 *
 *  @param data        Data returned from Twitter request
 *  @param requestType PDXRequestType
 *
 *  @since 1.0
 */
- (void)handleResponse:(NSDictionary *)data requestType:(PDXRequestType)requestType {
    switch (requestType) {
        case PDXRequestTypeGetUserInfo:
            [self handleGetUserInfo:data];
            break;
            
        case PDXRequestTypeGetFollowStatus:
            [self handleGetUserInfo:data];
            break;
            
        case PDXRequestTypeFollow:
            [self handleGetUserInfo:data];
            break;
            
        case PDXRequestTypeUnfollow:
            [self handleGetUserInfo:data];
            break;
            
        default:
            break;
    }
}

/**
 *  Handles results from a getUserInfo request
 *
 *  @param data Data returned from Twitter request
 *
 *  @since 1.0
 */
- (void)handleGetUserInfo:(NSDictionary *)data {
    NSDictionary *results = [self parseUsersLookup:data];
    [_delegate displayInfo:results];
}

/**
 *  Handles results from a getFollowStatus request
 *
 *  @param data Data returned from Twitter request
 *
 *  @since 1.0
 */
- (void)handleGetFollowStatus:(NSDictionary *)data {
    BOOL result = [self parseFriendshipsLookup:data];
    [_delegate toggleTwitter:result];
}

/**
 *  Handles results from a Follow request
 *
 *  @param data Data returned from Twitter request
 *
 *  @since 1.0
 */
- (void)handleFollow:(NSDictionary *)data {
    BOOL result = [self parseFriendshipsCreate:data];
    [_delegate toggleTwitter:result];
}

/**
 *  Handles results from an Unfollow request
 *
 *  @param data Data returned from Twitter request
 *
 *  @since 1.0
 */
- (void)handleUnfollow:(NSDictionary *)data {
    BOOL result = [self parseFriendshipsCreate:data];
    [_delegate toggleTwitter:result];
}

#pragma mark - Parse Data
// The names of the methods here are based on Twitter's API scheme

/**
 *  Parses results from a getUserInfo request
 *
 *  @param data Twitter data returned by the request
 *
 *  @return Dictionary containing: name, idString, photoURLString, description, and twitterName
 *
 *  @since 1.0
 */
- (NSDictionary *)parseUsersLookup:(NSDictionary *)data {
    // Extract the fields we want
    NSString *name = [self extractString:@"name" from:data];
    NSDictionary *splitNames = [self splitName:name];
    NSString *firstName = [splitNames valueForKey:@"firstName"];
    NSString *lastName = [splitNames valueForKey:@"lastName"];
    NSString *idString = [self extractString:@"id_str" from:data];
    NSString *photoURLString = [self extractString:@"profile_image_url" from:data];
    NSString *description = [self extractString:@"description" from:data];
    NSString *shortTwitterName = [self extractString:@"screen_name" from:data];
    NSString *twitterName = [NSString stringWithFormat:@"@%@", shortTwitterName];
    NSString *personalURL = [self parsePersonalURL:data];
    
    NSDictionary *results = @{ @"firstName" : firstName,
                               @"lastName" : lastName,
                               @"twitterName" : twitterName,
                               @"idString" : idString,
                               @"emailAddress" : @"",
                               @"phoneNumber" : @"",
                               @"wwwAddress" : personalURL,
                               @"twitterDescription" : description,
                               @"photoURL" : photoURLString,
                               };
    
    return results;
}

- (NSDictionary *)splitName:(NSString *)name {
    // Split name into firstName / lastName
    NSDictionary *splitNames;
    if (![name isEqualToString:@""]) {
        NSArray *nameArray = [name componentsSeparatedByString:@" "];
        NSString *firstWord = nameArray[0];
        if ([name isEqualToString:firstWord]) {
            // Name is just one word
            splitNames = @{ @"firstName" : name, @"lastName" : @"" };
         } else {
            // Name is multi-word
             splitNames = @{ @"firstName" : firstWord, @"lastName" : [name substringFromIndex:[firstWord length]] };
        }
    }
    
    return splitNames;
}

/*  The following two methods differ because Twitter returns a different data dictionary from a getFollowStatus request
    and a request to follow/unfollow an ID
*/


/**
 *  Checks if a request to follow/unfollow a user has been successful
 *
 *  @param data Data returned from the Twitter request
 *
 *  @return YES if user is now following the Twitter ID; NO if they are not
 *
 *  @since 1.0
 */
- (BOOL)parseFriendshipsCreate:(NSDictionary *)data {
    NSString *following = [data valueForKey:@"following"];
    if ([following isEqualToString:@"true"]) {
                
        return YES;
    }
    
    return NO;
}

/**
 *  Checks if the user is currently following a Twitter ID
 *
 *  @param data Data returned from the Twitter request
 *
 *  @return YES if they user currently follows the Twitter ID; NO if they are not
 *
 *  @since 1.0
 */
- (BOOL)parseFriendshipsLookup:(NSDictionary *)data {
    NSArray *connections = [data valueForKey:@"connections"];
    for (NSArray *item in connections) {
        for (NSString *connection in item) {
            if ([connection isEqualToString:@"following"]) {
                
                return YES;
            }
        }
    }
    
    return NO;
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

#pragma mark - Protocols

/**
 *  Toggles the Twitter follow status on/off
 *
 *  Is used by views that conform to PDXTwitterCommunicatorDelegate, so it is not implemented here
 *
 *  @param onOff YES if user follows the Twitter ID; NO if they don't
 *
 *  @since 1.0
 */
- (void)toggleTwitter:(BOOL)onOff {
    
}

/**
 *  Display info returned by a getUserInfo request
 *
 *  Is used by views that conform to PDXTwitterCommunicatorDelegate, so it is not implemented here
 *
 *  @param data Data dictionary producted by parsing a getUserInfo request
 *
 *  @since 1.0
 */
- (void)displayInfo:(NSDictionary *)data {

}

#pragma mark - Error Conditions

/**
 *  Present dialog if a data request returns nil instead of a data dictionary
 *
 *  @param error The error returned by the request
 *
 *  @since 1.0
 */
- (void)resultsDataEqualsNil:(NSError *)error {
    // TODO Present dialog to user if results == nil
    NSLog(@"[ERROR] An error occurred: %@", [error localizedDescription]);
}

/**
 *  Present dialog and log information if we get a non-expected HTTP response (i.e. a non-2xx response)
 *
 *  @param urlResponse The HTTP URL response we received
 *
 *  @since 1.0
 */
- (void)performRequestWithHandlerError:(NSHTTPURLResponse *)urlResponse {
    NSInteger statusCode = urlResponse.statusCode;
    NSLog(@"[ERROR] Server responded: status code %ld %@", (long)statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
    
}

/**
 *  We have tried to access the user's Twitter account (after they have said they would give us 
 *  permission), but we have not been able to do so as expected
 *
 *  @param error Error returned when we tried to access the account
 *
 *  @since 1.0
 */
- (void)requestAccessToAccountsError:(NSError *)error {
    // User has previously said they would give us permission to access their Twitter account
    // Check for error conditions
    
    // TODO Add methods to recover from errors
    NSLog(@"Error accessing user's Twitter account. Error: %@", error);
    switch (error.code) {
        case ACErrorUnknown:
            NSLog(@"Unknown error accessing user's Twitter account. Error: %@", error);
            break;
            
        case ACErrorAccountMissingRequiredProperty:
            NSLog(@"Major error accessing user's Twitter account. Error: %@ \
                  \nMost likely cause is new Twitter API", error);
            break;
            
        case ACErrorAccountAuthenticationFailed:
            NSLog(@"Error accessing user's Twitter account. Error: %@ \
                  \nHas user entered correct password?", error);
            break;
            
        case ACErrorAccountTypeInvalid:
            NSLog(@"Major error accessing user's Twitter account. Error: %@ \
                  \nMost likely cause is new Apple API to access Twitter", error);
            break;
            
        case ACErrorAccountAlreadyExists:
            NSLog(@"Major error accessing user's Twitter account. Error: %@ \
                  \nThis error should never be called, as we never try to create a new account", error);
            break;
            
        case ACErrorAccountNotFound:
            NSLog(@"Error accessing user's Twitter account. Error: %@ \
                  \nMost likely that user has deleted their Twitter account on this device", error);
            break;
            
        case ACErrorPermissionDenied:
            NSLog(@"Error accessing user's Twitter account. Error: %@ \
                  \nUser has denied (or revoked) their permission", error);
            break;
            
        case ACErrorAccessInfoInvalid:
            NSLog(@"Unknown error accessing user's Twitter account. Error: %@", error);
            break;
            
        case ACErrorClientPermissionDenied:
            NSLog(@"Error accessing user's Twitter account. Error: %@ \
                  \nUser has denied (or revoked) their permission", error);
            break;
            
        case ACErrorAccessDeniedByProtectionPolicy:
            NSLog(@"Error accessing user's Twitter account. Error: %@ \
                  \nUser is not able to give permission to access their Twitter account (if they have one)", error);
            break;
            
        case ACErrorCredentialNotFound:
            NSLog(@"Error accessing user's Twitter account. Error: %@ \
                  \nUser may have deleted their Twitter account from this device, or revoked their permission", error);
            break;
            
        case ACErrorFetchCredentialFailed:
            NSLog(@"Error accessing user's Twitter account. Error: %@ \
                  \nUser may have deleted their Twitter account from this device, or revoked their permission", error);
            break;
            
        case ACErrorStoreCredentialFailed:
            NSLog(@"Error accessing user's Twitter account. Error: %@ \
                  \nUser may have deleted their Twitter account from this device, or revoked their permission", error);
            break;
            
        case ACErrorRemoveCredentialFailed:
            NSLog(@"Major error accessing user's Twitter account. Error: %@ \
                  \nThis error should never be called, as we never try to remove an account's credentials", error);
            break;
            
        case ACErrorUpdatingNonexistentAccount:
            NSLog(@"Error accessing user's Twitter account. Error: %@ \
                  \nUser must have deleted their Twitter account from this device", error);
            break;
            
        case ACErrorInvalidClientBundleID:
            NSLog(@"Unknown error accessing user's Twitter account. Error: %@", error);
            break;
            
        default:
            break;
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


@end


