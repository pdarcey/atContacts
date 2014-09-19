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
 *  Prepares a request to send to Twitter's APIs using the user's Twitter credentials stored in Settings
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
                
                NSString *identifier = [self identifier];
                ACAccount *account = [store accountWithIdentifier:identifier];
                
                if (account) {
                    [self twitterRequest:account url:url getOrPost:getOrPost parameters:parameters requestType:requestType];
                } else {
                    NSArray *arrayOfAccounts = [store accountsWithAccountType:accountType];
                    
                    if ([arrayOfAccounts count] > 0) {
                        account = [arrayOfAccounts lastObject];
                        [self twitterRequest:account url:url getOrPost:getOrPost parameters:parameters requestType:requestType];
                    }
                }
            }
        }];
    } else {
        [_delegate displayErrorMessage:NSLocalizedString(@"This app doesn't work unless you give permission to use your Twitter account\n\nSorry", @"Use has denied permission to use Twitter account")];
    }
}

/**
 *  Sends a request to Twitter's API
 *
 *  @param account     The Twitter account to use
 *  @param url         Twitter API URL
 *  @param getOrPost   GET or POST type API
 *  @param parameters  Dictionary of additional parameters for the API (e.g. {@"screen_name" : @"twittername"})
 *  @param requestType PDXRequestType (see specific requests below)
 *
 *  @since 1.0
 */
- (void)twitterRequest:(ACAccount *)account url:(NSURL *)url getOrPost:(SLRequestMethod)getOrPost parameters:(NSDictionary *)parameters requestType:(PDXRequestType)requestType {
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:getOrPost URL:url parameters:parameters];
    
    request.account = account;
    
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
            [self performResponseError:error];
        }
        
    }];
}

#pragma mark - Specific requests
/**
 *  Get user info for twitterName
 *
 *  @param twitterName Twitter name to look up. Does NOT include the leading "@" symbol
 *
 *  @since 1.0
 */
- (void)getUserInfo:(NSString *)twitterName {
    _twitterName = twitterName;
    NSURL *url = [NSURL URLWithString: @"https://api.twitter.com/1.1/users/lookup.json"];
    NSDictionary *parameters = @{@"screen_name" : twitterName};
    SLRequestMethod get = SLRequestMethodGET;
    
    [self sendTwitterRequestTo:url getOrPost:get parameters:parameters requestType:PDXRequestTypeGetUserInfo];

}

/**
 *  Does the user currently follow the Twitter user with the ID idString?
 *
 *  Response from Twitter will be handled by handleResponse:(NSDictionary *)data requestType:(PDXRequestType)requestType
 *
 *  @param idString Twitter's unique ID string for users. Obtained from the getUserInfo query
 *
 *  @since 1.0
 */
- (void)getFollowStatus:(NSString *)idString {
    _twitterName = idString;
    NSURL *url = [NSURL URLWithString: @"https://api.twitter.com/1.1/friendships/lookup.json?"];
    NSDictionary *parameters = @{@"user_id" : idString};
    SLRequestMethod get = SLRequestMethodGET;
    
    [self sendTwitterRequestTo:url getOrPost:get parameters:parameters requestType:PDXRequestTypeGetFollowStatus];
    
}

/**
 *  Get person's Twitter photo
 *
 *  Note: Does NOT use Apple's Twitter API; uses NSURLSession instead
 *
 *  @param photoURL <#photoURL description#>
 *
 *  @since <#version number#>
 */
- (void)getUserImage:(NSString *)photoURL {
    NSURLSession *session = [NSURLSession sharedSession];
   
    [[session dataTaskWithURL:[NSURL URLWithString:photoURL]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                // TODO: Check NSURLResponse to ensure we received a valid response
                [_delegate displayUserImage:[UIImage imageWithData:data]];
                
            }] resume];
}


/**
 *  Sets the user's Twitter account to follow the Twitter user with the ID idString
 *
 *  @param idString Twitter's unique ID string for users. Obtained from the getUserInfo query
 *
 *  @since 1.0
 */
- (void)follow:(NSString *)idString {
    _twitterName = idString;
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
    _twitterName = idString;
    NSURL *url = [NSURL URLWithString: @"https://api.twitter.com/1.1/friendships/create.json"];
    NSDictionary *parameters = @{@"user_id" : idString, @"follow" : @"false"};
    SLRequestMethod post = SLRequestMethodPOST;
    
    [self sendTwitterRequestTo:url getOrPost:post parameters:parameters requestType:PDXRequestTypeUnfollow];
    
}

#pragma mark - Handle Responses

/**
 *  Function to replace null responses with @"" for data returned by Twitter
 *
 *  @param rootObject Data object from Twitter. Could be NSDictionary or NSArray
 *
 *  @return Object of same class as given, with null values replaced with @""
 *
 *  @since 1.0
 */
id removeNull(id rootObject) {
    if ([rootObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *sanitizedDictionary = [NSMutableDictionary dictionaryWithDictionary:rootObject];
        [rootObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id sanitized = removeNull(obj);
            if (!sanitized) {
                [sanitizedDictionary setObject:@"" forKey:key];
            } else {
                [sanitizedDictionary setObject:sanitized forKey:key];
            }
        }];
        return [NSMutableDictionary dictionaryWithDictionary:sanitizedDictionary];
    }
    
    if ([rootObject isKindOfClass:[NSArray class]]) {
        NSMutableArray *sanitizedArray = [NSMutableArray arrayWithArray:rootObject];
        [rootObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id sanitized = removeNull(obj);
            if (!sanitized) {
                [sanitizedArray replaceObjectAtIndex:[sanitizedArray indexOfObject:obj] withObject:@""];
            } else {
                [sanitizedArray replaceObjectAtIndex:[sanitizedArray indexOfObject:obj] withObject:sanitized];
            }
        }];
        return [NSMutableArray arrayWithArray:sanitizedArray];
    }
    
    if ([rootObject isKindOfClass:[NSNull class]]) {
        return (id)nil;
    } else {
        return rootObject;
    }
}

/**
 *  Chooses how to handle the response from a Twitter request
 *
 *  @param data        Data returned from Twitter request
 *  @param requestType PDXRequestType
 *
 *  @since 1.0
 */
- (void)handleResponse:(NSDictionary *)data requestType:(PDXRequestType)requestType {
    NSDictionary *sanitisedData = removeNull(data);
    
    switch (requestType) {
        case PDXRequestTypeGetUserInfo:
            [self handleGetUserInfo:sanitisedData];
            break;
            
        case PDXRequestTypeGetFollowStatus:
            [self handleGetFollowStatus:sanitisedData];
            break;
                        
        case PDXRequestTypeFollow:
            [self handleFollow:sanitisedData];
            break;
            
        case PDXRequestTypeUnfollow:
            [self handleUnfollow:sanitisedData];
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
    [_delegate followedOnTwitter:result];
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
    [_delegate followedOnTwitter:result];
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
    [_delegate followedOnTwitter:result];
}

#pragma mark - Parse Data
// The names of the methods here are based on Twitter's API scheme(s)

/**
 *  Parses results from a getUserInfo request
 *
 *  @param data Twitter data returned by the request
 *
 *  @return Dictionary containing: firstName, lastName, twitterName, idString, emailAddress, phoneNumber, wwwAddress,
 *                                 twitterDescription, photoURL and following
 *
 *  All objects in the dictionary are strings, except following, which is an NSNumber representation of a BOOL
 *
 *  @since 1.0
 */
- (NSDictionary *)parseUsersLookup:(NSDictionary *)data {
    // Extract the fields we want
    NSString *name = [self parseJSON:data forKey:@"name"];
    NSDictionary *splitNames = [self splitName:name];
    NSString *firstName = [splitNames valueForKey:@"firstName"];
    NSString *lastName = [splitNames valueForKey:@"lastName"];
    NSString *idString = [self parseJSON:data forKey:@"id_str"];
    NSString *photoURLString = [self parseJSON:data forKey:@"profile_image_url"];
    NSString *description = [self parseJSON:data forKey:@"description"];
    NSString *shortTwitterName = [self parseJSON:data forKey:@"screen_name"];
    NSString *twitterName = [NSString stringWithFormat:@"@%@", shortTwitterName];
    NSString *personalURL = [self parsePersonalURL:data];
    //    NSString *personalURL = [self parseJSON:data forKey:@"expanded_url"];
    if (!personalURL) {
        personalURL = [self parseJSON:data forKey:@"url"];
    }
    NSNumber *followingNumber = [self parseJSON:data forKey:@"following"];
    
    NSDictionary *results = @{ @"firstName"          : firstName,
                               @"lastName"           : lastName,
                               @"twitterName"        : twitterName,
                               @"idString"           : idString,
                               @"emailAddress"       : @"",
                               @"phoneNumber"        : @"",
                               @"wwwAddress"         : personalURL,
                               @"twitterDescription" : description,
                               @"photoURL"           : photoURLString,
                               @"following"          : followingNumber
                               };
    
    return results;
}

/**
 *  Parses a JSON dictionary for a key
 *
 *  @param data NSDictionary representation of JSON data
 *  @param key  Key to look for
 *
 *  @return Object for key (or nil, if not found)
 *
 *  @since 1.0
 */
- (id)parseJSON:(NSDictionary *)data forKey:(NSString *)key {
    id result;
    for (id object in data) {
        result = nil;
        if ([object isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in object) {
                result = [dict objectForKey:key];
                if (result) {
                    return result;
                }
            }
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            result = [(NSDictionary *)object objectForKey:key];
            if (result) {
                return result;
            } 
        }
    }
    return nil;
}

/**
 *  Splits a name string into firstName and lastName
 *
 *  First word of the string goes into firstName, the rest goes into lastName
 *
 *  @param name A string representing a name
 *
 *  @return Dictionary with two keys: firstName and lastName
 *
 *  @since 1.0
 */
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
             splitNames = @{ @"firstName" : firstWord, @"lastName" : [name substringFromIndex:[firstWord length] + 1] };
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
    BOOL following = [(NSNumber *)[data valueForKey:@"following"] boolValue];
    if (following) {
                
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
    NSDictionary *entityDict = [self parseJSON:data forKey:@"entities"];
    NSString *personalURL;
    if (entityDict) {
        NSDictionary *url = [entityDict valueForKey:@"url"];
        NSArray *urls = [url valueForKey:@"urls"];
        personalURL = [[urls valueForKey:@"expanded_url"] firstObject];
    }
    if (personalURL) {
        return personalURL;
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
    NSString *string = @"";
    if ([array count] > 0) {
        NSString *nullCheck = array[0];
        if ([nullCheck class] == [NSNull class]) {
            string = @"";
        } else {
            string = nullCheck;
        }
    }
    
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
- (void)followedOnTwitter:(BOOL)success {
    
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

/**
 *  Tells the view to display a message to the user
 *
 *  Is used by views that conform to PDXTwitterCommunicatorDelegate, so it is not implemented here
 *
 *  @param message Message to display
 *
 *  @since 1.0
 */
- (void)displayErrorMessage:(NSString *)message {
    
}

/**
 *  Display info returned by a getUserImage request
 *
 *  Is used by views that conform to PDXTwitterCommunicatorDelegate, so it is not implemented here
 *
 *  @param image Image returned by Twitter
 *
 *  @since 1.0
 */
- (void)displayUserImage:(UIImage *)image {
    
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
    [_delegate displayErrorMessage:NSLocalizedString(@"No Twitter use with this name", @"No data returned")];
    NSLog(@"[ERROR] An error occurred: %@", [error localizedDescription]);
}

/**
 *  Present dialog and log information if we get a non-expected HTTP response (i.e. a non-2xx response)
 *
 *  @param urlResponse The HTTP URL response we received
 *
 *  @since 1.0
 */
- (void)performResponseError:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"[ERROR] An error occurred: %@", [error localizedDescription]];
    [_delegate displayErrorMessage:message];
    
    NSLog(@"%@", message);
    
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

    NSString *message = @"";
    
    switch (statusCode) {
        case 200:
            message = [NSString stringWithFormat:NSLocalizedString(@"There has been a problem connecting with Twitter", @"OK")];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"200", @"OK");
            
            break;
            
        case 304:
            message = [NSString stringWithFormat:NSLocalizedString(@"There has been a problem connecting with Twitter", @"Not Modified")];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"304", @"Not Modified");
            
            break;
            
        case 400:
            message = [NSString stringWithFormat:NSLocalizedString(@"There has been a problem connecting with Twitter", @"Bad Request")];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"400", @"Bad Request");
            
            break;
            
        case 401:
            message = [NSString stringWithFormat:NSLocalizedString(@"There has been a problem connecting with Twitter", @"Unauthorized")];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"401", @"Unauthorized");
            
            break;
            
        case 403:
            message = [NSString stringWithFormat:NSLocalizedString(@"There has been a problem connecting with Twitter", @"Forbidden")];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"403", @"Forbidden");
            
            break;
            
        case 404:
            message = [NSString stringWithFormat:NSLocalizedString(@"No user with Twitter name %@", @"Not Found"), _twitterName];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"404", @"Not Found");
            
            break;
            
        case 406:
            message = [NSString stringWithFormat:NSLocalizedString(@"There has been a problem connecting with Twitter", @"Not Acceptable")];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"406", @"Not Acceptable");
            
            break;
            
        case 410:
            message = [NSString stringWithFormat:NSLocalizedString(@"There has been a problem connecting with Twitter", @"Gone")];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"410", @"Gone");
            
            break;
            
        case 420:
            message = [NSString stringWithFormat:NSLocalizedString(@"There has been a problem connecting with Twitter", @"Enhance Your Calm")];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"420", @"Enhance Your Calm");
            
            break;
            
        case 422:
            message = [NSString stringWithFormat:NSLocalizedString(@"There has been a problem connecting with Twitter", @"Unprocessable Entity")];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"422", @"Unprocessable Entity");
            
            break;
            
        case 429:
            message = [NSString stringWithFormat:NSLocalizedString(@"There has been a problem connecting with Twitter", @"Too Many Requests")];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"429", @"Too Many Requests");
            
            break;
            
        case 500:
            message = [NSString stringWithFormat:NSLocalizedString(@"There has been a problem connecting with Twitter", @"Internal Server Error")];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"500", @"Internal Server Error");
            
            break;
            
        case 502:
            message = [NSString stringWithFormat:NSLocalizedString(@"There has been a problem connecting with Twitter", @"Bad Gateway")];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"502", @"Bad Gateway");
            
            break;
            
        case 503:
            message = [NSString stringWithFormat:NSLocalizedString(@"There has been a problem connecting with Twitter", @"Service Unavailable")];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"503", @"Service Unavailable");
            
            break;
            
        case 504:
            message = [NSString stringWithFormat:NSLocalizedString(@"There has been a problem connecting with Twitter", @"Gateway timeout")];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"504", @"Gateway timeout");
            
            break;
            

        default:
            message = [NSString stringWithFormat:@"[ERROR] Server responded: status code %ld %@", (long)statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]];
            [_delegate displayErrorMessage:message];
            NSLog(@"%@", message);

            break;
    }
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
    NSString *message = @"";
    
    switch (error.code) {
        case ACErrorUnknown:
            message = [NSString stringWithFormat:@"Unknown error accessing user's Twitter account. Error: %@", error];
            [_delegate displayErrorMessage:message];
            
            NSLog(@"%@", message);
            break;
            
        case ACErrorAccountMissingRequiredProperty:
            message = [NSString stringWithFormat:@"Major error accessing user's Twitter account. Error: %@ \
                                 \nMost likely cause is new Twitter API", error];
            [_delegate displayErrorMessage:message];
            
            NSLog(@"%@", message);
            break;
            
        case ACErrorAccountAuthenticationFailed:
            message = [NSString stringWithFormat:@"Error accessing user's Twitter account. Error: %@ \
                                 \nHas user entered correct password?", error];
            [_delegate displayErrorMessage:message];
            
            NSLog(@"%@", message);
            break;
            
        case ACErrorAccountTypeInvalid:
            message = [NSString stringWithFormat:@"Major error accessing user's Twitter account. Error: %@ \
                                 \nMost likely cause is new Apple API to access Twitter", error];
            [_delegate displayErrorMessage:message];
            
            NSLog(@"%@", message);
            break;
            
        case ACErrorAccountAlreadyExists:
            message = [NSString stringWithFormat:@"Major error accessing user's Twitter account. Error: %@ \
                                 \nThis error should never be called, as we never try to create a new account", error];
            [_delegate displayErrorMessage:message];
            
            NSLog(@"%@", message);
            break;
            
        case ACErrorAccountNotFound:
            message = [NSString stringWithFormat:@"Error accessing user's Twitter account. Error: %@ \
                                 \nMost likely that user has deleted their Twitter account on this device", error];
            [_delegate displayErrorMessage:message];
            
            NSLog(@"%@", message);
            break;
            
        case ACErrorPermissionDenied:
            message = [NSString stringWithFormat:@"Error accessing user's Twitter account. Error: %@ \
                                 \nUser has denied (or revoked) their permission", error];
            [_delegate displayErrorMessage:message];

            NSLog(@"%@", message);
            break;

        case ACErrorAccessInfoInvalid:
            message = [NSString stringWithFormat:@"Unknown error accessing user's Twitter account. Error: %@", error];
            [_delegate displayErrorMessage:message];

            NSLog(@"%@", message);
            break;

        case ACErrorClientPermissionDenied:
            message = [NSString stringWithFormat:@"Error accessing user's Twitter account. Error: %@ \
            \nUser has denied (or revoked) their permission)", error];
            [_delegate displayErrorMessage:message];

            NSLog(@"%@", message);
            break;

        case ACErrorAccessDeniedByProtectionPolicy:
            message = [NSString stringWithFormat:@"Error accessing user's Twitter account. Error: %@ \
            \nUser is not able to give permission to access their Twitter account (if they have one)", error];
            [_delegate displayErrorMessage:message];

            NSLog(@"%@", message);
            break;

        case ACErrorCredentialNotFound:
            message = [NSString stringWithFormat:@"Error accessing user's Twitter account. Error: %@ \
                                \nUser may have deleted their Twitter account from this device, or revoked their permission", error];
            [_delegate displayErrorMessage:message];

            NSLog(@"%@", message);
            break;

        case ACErrorFetchCredentialFailed:
            message = [NSString stringWithFormat:@"Error accessing user's Twitter account. Error: %@ \
                                \nUser may have deleted their Twitter account from this device, or revoked their permission", error];
            [_delegate displayErrorMessage:message];

            NSLog(@"%@", message);
            break;

        case ACErrorStoreCredentialFailed:
            message = [NSString stringWithFormat:@"Error accessing user's Twitter account. Error: %@ \
                                \nUser may have deleted their Twitter account from this device, or revoked their permission", error];
            [_delegate displayErrorMessage:message];

            NSLog(@"%@", message);
            ;
            break;

        case ACErrorRemoveCredentialFailed:
            message = [NSString stringWithFormat:@"Major error accessing user's Twitter account. Error: %@ \
                                \nThis error should never be called, as we never try to remove an account's credentials", error];
            [_delegate displayErrorMessage:message];

            NSLog(@"%@", message);
            break;

        case ACErrorUpdatingNonexistentAccount:
            message = [NSString stringWithFormat:@"Error accessing user's Twitter account. Error: %@ \
                                \nUser must have deleted their Twitter account from this device", error];
            [_delegate displayErrorMessage:message];

            NSLog(@"%@", message);
            break;

        case ACErrorInvalidClientBundleID:
            message = [NSString stringWithFormat:@"Unknown error accessing user's Twitter account. Error: %@", error];
            [_delegate displayErrorMessage:message];

            NSLog(@"%@", message);
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
 *  Returns the account type.
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

/*
 *  Returns the account store.
 *  If the account doesn't already exist, it is created.
 */
- (NSString *)identifier {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *identifier = [defaults valueForKey:@"defaultTwitterAccount"];
    
    return identifier;
}

/*
 *  Returns the account store.
 *  If the account doesn't already exist, it is created.
 */
- (void)setDefaultTwitterAccount:(NSString *)identifier {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:identifier forKey:@"defaultTwitterAccount"];
    
}

/*
 *  Returns the default Twitter account to use (or nil if no Twitter account is set up)
 *
 */
- (ACAccount *)defaultTwitterAccount {
    ACAccountStore *store = [self accountStore];
    NSString *identifier = [self identifier];
    ACAccountType *accountType = [self accountType];
    ACAccount *account = [self twitterAccountWithIdentifier:identifier];
    
    if (account) {
        return account;
    } else {
        NSArray *arrayOfAccounts = [store accountsWithAccountType:accountType];
        ACAccount *account;
        if ([arrayOfAccounts count] == 1) {
            // Only one Twitter account is set up in Settings; make it the default
            account = (ACAccount *)arrayOfAccounts[0];
            NSString *identifier = [account identifier];
            [self setDefaultTwitterAccount:identifier];
            
            return account;
        }
        
        if ([arrayOfAccounts count] > 0) {
            account = [arrayOfAccounts lastObject];
            NSArray *accountIdentifiers = [self arrayOfAccountIdentifiers:arrayOfAccounts];
            account = [self askForDefaultTwitterAccount:accountIdentifiers];
            NSString *identifier = [account identifier];
            [self setDefaultTwitterAccount:identifier];
            
            return account;
        }
    }
    return nil;

}

- (ACAccount *)twitterAccountWithIdentifier:(NSString *)identifier {
    ACAccountStore *store = [self accountStore];
    ACAccount *account = [store accountWithIdentifier:identifier];
    
    return account;
}

- (NSArray *)arrayOfAccountIdentifiers:(NSArray *)arrayOfAccounts {
    NSMutableArray *identifierArray = [NSMutableArray new];
    for (ACAccount *account in arrayOfAccounts) {
        NSString *identifier = [account identifier];
        [identifierArray addObject:identifier];
    }
    NSArray *arrayOfAccountIdentifiers = [NSArray arrayWithArray:identifierArray];
    return arrayOfAccountIdentifiers;
}

- (ACAccount *)askForDefaultTwitterAccount:(NSArray *)arrayOfAccountIdentifiers {
    // TODO Present account identifiers and allow user to select one. Return it as the default
    
    // *** Replace this block with actual code ***
    NSString *defaultIdentifier = (NSString *)[arrayOfAccountIdentifiers lastObject];
    ACAccount *defaultAccount = [self twitterAccountWithIdentifier:defaultIdentifier];
    
    // *** End of replacement block ***
    
    return defaultAccount; // placeholder
}

@end

