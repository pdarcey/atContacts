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

- (void)sendTwitterRequestTo:(NSURL *)url getOrPost:(SLRequestMethod)getOrPost parameters:(NSDictionary *)parameters requestType:(PDXRequestType)requestType {
    if (![self userDeniedPermission] && ![self userHasNoAccount]) {
        // Actually access user's Twitter account to get info
        [_accountStore requestAccessToAccountsWithType:_twitterType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted == YES) {
                NSArray *arrayOfAccounts = [_accountStore accountsWithAccountType:_twitterType];
                
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

- (void)getUserInfo:(NSString *)twitterName {
    NSURL *url = [NSURL URLWithString: @"https://api.twitter.com/1.1/users/lookup.json"];
    NSDictionary *parameters = @{@"screen_name" : twitterName};
    SLRequestMethod get = SLRequestMethodGET;
    
    [self sendTwitterRequestTo:url getOrPost:get parameters:parameters requestType:PDXRequestTypeGetUserInfo];

}

- (void)getFollowStatus:(NSString *)idString {
    NSURL *url = [NSURL URLWithString: @"https://api.twitter.com/1.1/friendships/lookup.json?"];
    NSDictionary *parameters = @{@"user_id" : idString};
    SLRequestMethod get = SLRequestMethodGET;
    
    [self sendTwitterRequestTo:url getOrPost:get parameters:parameters requestType:PDXRequestTypeGetFollowStatus];
    
}

- (void)follow:(NSString *)idString {
    NSURL *url = [NSURL URLWithString: @"https://api.twitter.com/1.1/friendships/create.json"];
    NSDictionary *parameters = @{@"user_id" : idString, @"follow" : @"true"};
    SLRequestMethod post = SLRequestMethodPOST;
    
    [self sendTwitterRequestTo:url getOrPost:post parameters:parameters requestType:PDXRequestTypeFollow];
    
}

- (void)unfollow:(NSString *)idString {
    NSURL *url = [NSURL URLWithString: @"https://api.twitter.com/1.1/friendships/create.json"];
    NSDictionary *parameters = @{@"user_id" : idString, @"follow" : @"false"};
    SLRequestMethod post = SLRequestMethodPOST;
    
    [self sendTwitterRequestTo:url getOrPost:post parameters:parameters requestType:PDXRequestTypeUnfollow];
    
}

#pragma mark - Handle Responses

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

- (void)handleGetUserInfo:(NSDictionary *)data {

    NSDictionary *results = [self parseUsersLookup:data];
    [self displayInfo:results];
}

- (void)handleGetFollowStatus:(NSDictionary *)data {
    BOOL result = [self parseFriendshipsLookup:data];
    [self toggleTwitter:result];
}

- (void)handleFollow:(NSDictionary *)data {
    BOOL result = [self parseFriendshipsCreate:data];
    [self toggleTwitter:result];
}

- (void)handleUnfollow:(NSDictionary *)data {
    BOOL result = [self parseFriendshipsCreate:data];
    [self toggleTwitter:result];
}

#pragma mark - Parse Data
// The names of the methods here are based on Twitter's API scheme

- (NSDictionary *)parseUsersLookup:(NSDictionary *)data {
    // Extract the fields we want
    NSString *name = [self extractString:@"name" from:data];
    NSString *idString = [self extractString:@"id_str" from:data];
    NSString *photoURLString = [self extractString:@"profile_image_url" from:data];
    NSString *description = [self extractString:@"description" from:data];
    NSString *shortTwitterName = [self extractString:@"screen_name" from:data];
    NSString *twitterName = [NSString stringWithFormat:@"@%@", shortTwitterName];
    NSString *personalURL = [self parsePersonalURL:data];
    
    NSDictionary *results = @{ @"name" : name, @"idString" :idString, @"photoURLString" : photoURLString, @"personalURL" : personalURL, @"description" : description, @"twitterName" : twitterName };
    
    return results;
   
}

- (BOOL)parseFriendshipsCreate:(NSDictionary *)data {
    NSString *following = [data valueForKey:@"following"];
    if ([following isEqualToString:@"true"]) {
                
        return YES;
    }
    
    return NO;
}

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

- (void)toggleTwitter:(BOOL)onOff {
    
}

- (void)displayInfo:(NSDictionary *)data {
    
}

#pragma mark - Error Conditions

- (void)resultsDataEqualsNil:(NSError *)error {
    // TODO Present dialog to user if results == nil
    NSLog(@"[ERROR] An error occurred: %@", [error localizedDescription]);
}

- (void)performRequestWithHandlerError:(NSHTTPURLResponse *)urlResponse {
    NSInteger statusCode = urlResponse.statusCode;
    NSLog(@"[ERROR] Server responded: status code %ld %@", (long)statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
    
}

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


