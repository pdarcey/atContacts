//
//  PDXTwitterCommunicator.m
//  atContacts
//
//  Created by Paul Darcey on 7/09/2014.
//  © 2014 Paul Darcey. All rights reserved.
//

#import "PDXTwitterCommunicator.h"
#import "PDXAppDelegate.h"

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

    if ([self isPreApprovedPresented]) {
        // Actually access user's Twitter account to get info
        [store requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted == YES) {
                [self setUserDefault:kUserDefaultTwitterApproved to:YES];
                [self setUserDefault:kUserDefaultTwitterDenied to:NO];
                [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:NO];
                
                NSString *identifier = [self identifier];
                ACAccount *account = [store accountWithIdentifier:identifier];
                
                if (account) {
                    [self twitterRequest:account url:url getOrPost:getOrPost parameters:parameters requestType:requestType];
                } else {
                    NSArray *arrayOfAccounts = [store accountsWithAccountType:accountType];
                    
                    if ([arrayOfAccounts count] > 0) {
                        account = [arrayOfAccounts lastObject];
                        [self twitterRequest:account url:url getOrPost:getOrPost parameters:parameters requestType:requestType];
                    } else {
                        // No accounts are set up!
                        [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:YES];
                        [self displayNoTwitterDialog];
                    }
                }
            } else {
                [self setUserDefault:kUserDefaultTwitterApproved to:NO];
                [self setUserDefault:kUserDefaultTwitterDenied to:YES];
                [self displayDeniedDialog];
                
            }
        }];
    } else {
            UIAlertController *initialDialog = [self preApprovalDialog];
            [_delegate displayAlert:initialDialog];
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
    NSURL *url = [NSURL URLWithString:kTwitterAPIURLUsersLookup];
    NSDictionary *parameters = @{kTwitterParameterScreenName :twitterName};
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
    NSURL *url = [NSURL URLWithString:kTwitterAPIURLFriendshipsLookup];
    NSDictionary *parameters = @{kTwitterParameterUserID : idString};
    SLRequestMethod get = SLRequestMethodGET;
    
    [self sendTwitterRequestTo:url getOrPost:get parameters:parameters requestType:PDXRequestTypeGetFollowStatus];
    
}

/**
 *  Get person's Twitter photo
 *
 *  Note: Does NOT use Apple's Twitter API; uses NSURLSession instead
 *
 *  @param photoURL URL for the person's photo
 *
 *  @since 1.0
 */
- (void)getUserImage:(NSString *)photoURL {
    NSURLSession *session = [NSURLSession sharedSession];
   
    [[session dataTaskWithURL:[NSURL URLWithString:photoURL]
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

                if (response) {

                    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                        NSInteger statusCode = httpResponse.statusCode;

                        if (statusCode == 200) {
                            [_delegate displayUserImage:[UIImage imageWithData:data]];
                        } else {
                            NSLog(@"Error getting image. Details = %ld: %@", (long)httpResponse.statusCode, httpResponse.description);
                        }
                    }
                }
                
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
    NSURL *url = [NSURL URLWithString:kTwitterAPIURLFriendshipsCreate];
    NSDictionary *parameters = @{kTwitterParameterUserID : idString, kTwitterParameterFollow : kTwitterParameterTrue};
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
    NSURL *url = [NSURL URLWithString:kTwitterAPIURLFriendshipsCreate];
    NSDictionary *parameters = @{kTwitterParameterUserID : idString, kTwitterParameterFollow : kTwitterParameterFalse};
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
                [sanitizedDictionary setObject:kBlankString forKey:key];
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
                [sanitizedArray replaceObjectAtIndex:[sanitizedArray indexOfObject:obj] withObject:kBlankString];
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
 *  Chooses how to handle the response from a Twitter request. We expect only one of four possible responses.
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
 *  All objects in the dictionary are strings, except kPersonFollowing, which is an NSNumber representation of a BOOL
 *
 *  @since 1.0
 */
- (NSDictionary *)parseUsersLookup:(NSDictionary *)data {
    // Extract the fields we want
    NSString *name = [self parseJSON:data forKey:kTwitterParameterName];
    NSDictionary *splitNames = [self splitName:name];
    NSString *firstName = [splitNames valueForKey:kPersonFirstName];
    NSString *lastName = [splitNames valueForKey:kPersonLastName];
    NSString *idString = [self parseJSON:data forKey:kTwitterParameterIDStr];
    NSString *photoURLString = [self parseJSON:data forKey:kTwitterParameterProfileImageUrl];
    NSString *description = [self parseJSON:data forKey:kTwitterParameterDescription];
    NSString *shortTwitterName = [self parseJSON:data forKey:kTwitterParameterScreenName];
    NSString *twitterName = [NSString stringWithFormat:@"@%@", shortTwitterName];
    NSString *personalURL = [self parsePersonalURL:data];
    //    NSString *personalURL = [self parseJSON:data forKey:@"expanded_url"];
    if ([personalURL isEqualToString:kBlankString]) {
        personalURL = [self parseJSON:data forKey:kTwitterParameterURL];
    }
    NSNumber *followingNumber = [self parseJSON:data forKey:kTwitterParameterFollowing];
    
    NSDictionary *results = @{ kPersonFirstName             : firstName,
                               kPersonLastName              : lastName,
                               kPersonTwitterName           : twitterName,
                               kPersonIDString              : idString,
                               kPersonEmailAddress          : @"",
                               kPersonPhoneNumber           : @"",
                               kPersonWebAddress            : personalURL,
                               kPersonTwitterDescription    : description,
                               kPersonPhotoURL              : photoURLString,
                               kPersonFollowing             : followingNumber
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
    assert(name != nil);

    if (![name isEqualToString:kBlankString]) {
        NSArray *nameArray = [name componentsSeparatedByString:@" "];
        NSString *firstWord = nameArray[0];

        if ([name isEqualToString:firstWord]) {
            // Name is just one word
            splitNames = @{ kPersonFirstName : name, kPersonLastName : @"" };
         } else {
            // Name is multi-word
             splitNames = @{ kPersonFirstName : firstWord, kPersonLastName : [name substringFromIndex:[firstWord length] + 1] };
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
    BOOL following = [(NSNumber *)[data valueForKey:kPersonFollowing] boolValue];

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
    NSArray *connections = [data valueForKey:kTwitterParameterConnections];

    for (NSArray *item in connections) {

        for (NSString *connection in item) {

            if ([connection isEqualToString:kTwitterParameterFollowing]) {
                
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
    NSDictionary *entityDict = [self parseJSON:data forKey:kTwitterParameterEntities];
    NSString *personalURL;

    if (entityDict) {
        NSDictionary *url = [entityDict valueForKey:kTwitterParameterURL];
        NSArray *urls = [url valueForKey:kTwitterParameterURLS];
        personalURL = [[urls valueForKey:kTwitterParameterExpandedURL] firstObject];
    }

    if (personalURL) {
        return personalURL;
    }

    return kBlankString;
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
    NSString *string = kBlankString;

    if ([array count] > 0) {
        NSString *nullCheck = array[0];

        if ([nullCheck class] == [NSNull class]) {
            string = kBlankString;
        } else {
            string = nullCheck;
        }
    }
    
    return string;
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
    [_delegate displayErrorMessage:NSLocalizedString(@"No Twitter user with this name", @"No data returned")];
    NSLog(@"[ERROR] An error occurred: %@", [error localizedDescription]);
}

/**
 *  Present dialog and log information if we get a non-expected HTTP response (i.e. a non-2xx response)
 *
 *  This is for HTTP responses coming from the general network, not from Twitter
 *
 *  @param urlResponse The HTTP URL response we received
 *
 *  @since 1.0
 */
- (void)performResponseError:(NSError *)error {
    NSString *message = [error localizedDescription];
    [_delegate displayErrorMessage:message];
    
    NSLog(@"[ERROR] An error occurred: %@", [error localizedDescription]);
    
}

/**
 *  Present dialog and log information if we get a non-expected HTTP response (i.e. a non-2xx response)
 *
 *  These HTTP responses come from Twitter
 *
 *  @param urlResponse The HTTP URL response we received
 *
 *  @since 1.0
 */
- (void)performRequestWithHandlerError:(NSHTTPURLResponse *)urlResponse {
    // Twitter API responses: https://dev.twitter.com/overview/api/response-codes
    
    NSInteger statusCode = urlResponse.statusCode;
    NSString *message = kBlankString;
    
    switch (statusCode) {
        case 200:
            // OK
            // NSLog(@"Twitter Error:%@ %@", @"200", @"OK");
            
            break;
            
        case 304:
            message = NSLocalizedString(@"There has been a problem connecting with Twitter", @"Not Modified");
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"304", @"Not Modified");
            
            break;
            
        case 400:
            message = NSLocalizedString(@"There has been a problem connecting with Twitter", @"Bad Request");
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"400", @"Bad Request");
            
            break;
            
        case 401:
            message = NSLocalizedString(@"There has been a problem connecting with Twitter", @"Unauthorized");
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"401", @"Unauthorized");
            
            break;
            
        case 403:
            message = NSLocalizedString(@"This user protects their Twitter account\n\nYou will have to request to follow them in Twitter; they may or may not approve your request", @"Forbidden");
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"403", @"Forbidden");
            
            break;
            
        case 404:
            message = [NSString stringWithFormat:NSLocalizedString(@"No user with Twitter name @%@", @"Not Found"), _twitterName];
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"404", @"Not Found");
            
            break;
            
        case 406:
            message = NSLocalizedString(@"There has been a problem connecting with Twitter", @"Not Acceptable");
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"406", @"Not Acceptable");
            
            break;
            
        case 410:
            message = NSLocalizedString(@"There has been a problem connecting with Twitter", @"Gone");
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"410", @"Gone");
            
            break;
            
        case 420:
            message = NSLocalizedString(@"There has been a problem connecting with Twitter", @"Enhance Your Calm");
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"420", @"Enhance Your Calm");
            
            break;
            
        case 422:
            message = NSLocalizedString(@"There has been a problem connecting with Twitter", @"Unprocessable Entity");
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"422", @"Unprocessable Entity");
            
            break;
            
        case 429:
            message = NSLocalizedString(@"There has been a problem connecting with Twitter", @"Too Many Requests");
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"429", @"Too Many Requests");
            
            break;
            
        case 500:
            message = NSLocalizedString(@"There has been a problem connecting with Twitter", @"Internal Server Error");
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"500", @"Internal Server Error");
            
            break;
            
        case 502:
            message = NSLocalizedString(@"There has been a problem connecting with Twitter", @"Bad Gateway");
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"502", @"Bad Gateway");
            
            break;
            
        case 503:
            message = NSLocalizedString(@"There has been a problem connecting with Twitter", @"Service Unavailable");
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"503", @"Service Unavailable");
            
            break;
            
        case 504:
            message = NSLocalizedString(@"There has been a problem connecting with Twitter", @"Gateway timeout");
            [_delegate displayErrorMessage:message];
            NSLog(@"Twitter Error:%@ %@", @"504", @"Gateway timeout");
            
            break;
            

        default:
            message = NSLocalizedString(@"There has been a problem connecting with Twitter", @"Default HTTP response error message");
            [_delegate displayErrorMessage:message];
            NSLog(@"%@", [NSString stringWithFormat:@"[ERROR] Server responded: status code %ld %@", (long)statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]]);

            break;
    }
}

/**
 *  We have tried to access the user's Twitter account (after they have said they would give us 
 *  permission), but we have not been able to do so as expected
 *
 *  These error codes come from Apples Account framework
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
    NSString *message = kBlankString;
    UIAlertController *alert;
    
    switch (error.code) {
        case ACErrorUnknown:
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account", @"ACErrorUnknown");
            [self setUserDefault:kUserDefaultTwitterApproved to:YES];
            [self setUserDefault:kUserDefaultTwitterDenied to:NO];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:NO];

            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, @"Unknown error accessing user's Twitter account");

            break;
            
        case ACErrorAccountMissingRequiredProperty:
            [self setUserDefault:kUserDefaultTwitterApproved to:NO];
            [self setUserDefault:kUserDefaultTwitterDenied to:YES];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:NO];
            
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account", @"ACErrorAccountMissingRequiredProperty");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, @"Most likely cause is new Twitter API");
            
            break;
            
        case ACErrorAccountAuthenticationFailed:
            [self setUserDefault:kUserDefaultTwitterApproved to:NO];
            [self setUserDefault:kUserDefaultTwitterDenied to:NO];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:YES];

            message = NSLocalizedString(@"There has been a problem accessing your Twitter account\n\nHave you entered correct password?", @"ACErrorAccountAuthenticationFailed");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, message);
            
            break;
            
        case ACErrorAccountTypeInvalid:
            [self setUserDefault:kUserDefaultTwitterApproved to:NO];
            [self setUserDefault:kUserDefaultTwitterDenied to:YES];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:NO];
            
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account", @"ACErrorAccountTypeInvalid");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, @"Most likely cause is new Twitter API");
           
            break;
            
        case ACErrorAccountAlreadyExists:
            [self setUserDefault:kUserDefaultTwitterApproved to:NO];
            [self setUserDefault:kUserDefaultTwitterDenied to:YES];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:NO];
            
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account", @"ACErrorAccountAlreadyExists");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, @"This error should never be called, as we never try to create a new account");
            
            break;
            
        case ACErrorAccountNotFound:
            [self setUserDefault:kUserDefaultTwitterApproved to:NO];
            [self setUserDefault:kUserDefaultTwitterDenied to:NO];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:YES];
            
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account\n\nHave you deleted your Twitter account on this device?", @"ACErrorAccountNotFound");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, message);
            
            break;
            
        case ACErrorPermissionDenied:
            [self setUserDefault:kUserDefaultTwitterApproved to:NO];
            [self setUserDefault:kUserDefaultTwitterDenied to:YES];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:NO];
            
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account\n\nYou have denied (or revoked) permission for this app to use Twitter", @"ACErrorPermissionDenied");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, message);
            
            break;
            
        case ACErrorAccessInfoInvalid:
            [self setUserDefault:kUserDefaultTwitterApproved to:NO];
            [self setUserDefault:kUserDefaultTwitterDenied to:YES];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:NO];
            
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account", @"ACErrorAccessInfoInvalid");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, message);
            
            break;
            
        case ACErrorClientPermissionDenied:
            [self setUserDefault:kUserDefaultTwitterApproved to:NO];
            [self setUserDefault:kUserDefaultTwitterDenied to:YES];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:NO];
            
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account\n\nYou have denied (or revoked) permission to access Twitter", @"ACErrorClientPermissionDenied");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, message);
            
            break;
            
        case ACErrorAccessDeniedByProtectionPolicy:
            [self setUserDefault:kUserDefaultTwitterApproved to:NO];
            [self setUserDefault:kUserDefaultTwitterDenied to:YES];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:NO];
            
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account\n\nAsk your administrator to allow permission", @"ACErrorAccessDeniedByProtectionPolicy");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, @"User is not able to give permission to access their Twitter account (if they have one)");
            
            break;
            
        case ACErrorCredentialNotFound:
            [self setUserDefault:kUserDefaultTwitterApproved to:NO];
            [self setUserDefault:kUserDefaultTwitterDenied to:YES];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:YES];
            
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account\n\nHave you deleted your Twitter account from this device, or revoked permission for this app?", @"ACErrorCredentialNotFound");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, message);
            
            break;
            
        case ACErrorFetchCredentialFailed:
            [self setUserDefault:kUserDefaultTwitterApproved to:NO];
            [self setUserDefault:kUserDefaultTwitterDenied to:YES];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:YES];
            
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account\n\nHave you deleted your Twitter account from this device, or revoked permission for this app?", @"ACErrorFetchCredentialFailed");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, message);
            
            break;
            
        case ACErrorStoreCredentialFailed:
            [self setUserDefault:kUserDefaultTwitterApproved to:NO];
            [self setUserDefault:kUserDefaultTwitterDenied to:YES];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:YES];
            
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account\n\nHave you deleted your Twitter account from this device, or revoked permission for this app?", @"ACErrorStoreCredentialFailed");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, message);
            
            break;
            
        case ACErrorRemoveCredentialFailed:
            [self setUserDefault:kUserDefaultTwitterApproved to:NO];
            [self setUserDefault:kUserDefaultTwitterDenied to:NO];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:YES];
            
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account", @"ACErrorRemoveCredentialFailed");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, @"This error should never be called, as we never try to remove an account's credentials");
            
            break;
            
        case ACErrorUpdatingNonexistentAccount:
            [self setUserDefault:kUserDefaultTwitterApproved to:NO];
            [self setUserDefault:kUserDefaultTwitterDenied to:YES];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:YES];
            
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account\n\nHave you deleted your Twitter account from this device?", @"ACErrorUpdatingNonexistentAccount");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, message);
            
            break;
            
        case ACErrorInvalidClientBundleID:
            [self setUserDefault:kUserDefaultTwitterApproved to:NO];
            [self setUserDefault:kUserDefaultTwitterDenied to:YES];
            [self setUserDefault:kUserDefaultTwitterNoTwitterAccount to:NO];
            
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account", @"ACErrorInvalidClientBundleID");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, message);
            
            break;
            
        default:
            message = NSLocalizedString(@"There has been a problem accessing your Twitter account", @"default Error message acccessing Twitter");
            alert = [self basicAlert:message];
            [_delegate displayAlert:alert];
            
            NSLog(@"Error: %@ - %@", error, message);
            
            break;
    }
}

# pragma mark - Alerts

/**
 *  Formats a generic alert message, ready for presentation
 *
 *  @param message The message to go in the body of the alert. If nil, a default is used
 *  @param title   The title of the alert. If nil, a default is used
 *
 *  @return A formatted alert message
 *
 *  @since 1.0
 */
- (UIAlertController *)basicAlert:(NSString *)message title:(NSString *)title {
    if (!title) {
        title = NSLocalizedString(kAlertTitle, @"Default title for alerts");
    }
    
    if (!message) {
        message = NSLocalizedString(@"An unexpected error occured", "Blank message");
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertController __weak *weakAlert = alert;
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [weakAlert dismissViewControllerAnimated:YES completion:nil];
                                                          }];
    [alert addAction:defaultAction];
    
    return alert;
}

/**
 *  Formats a generic alert message, ready for presentation. Convenience method that uses a default title
 *
 *  @param message The message to go in the body of the alert. If nil, a default is used
 *
 *  @return A formatted alert message
 *
 *  @since 1.0
 */
- (UIAlertController *)basicAlert:(NSString *)message {
    NSString *title = NSLocalizedString(kAlertTitle, @"Default title for alerts");

    UIAlertController *alert = [self basicAlert:message title:title];

    return alert;
}

/**
 *  Formats a Twitter Pre-Approval alert
 *
 *  @return A formatted pre-approval alert, ready for presentation
 *
 *  @since 1.0
 */
- (UIAlertController *)preApprovalDialog {
    NSString *title = NSLocalizedString(@"Access to Twitter", @"Title for pre-approval dialog");
    NSString *message = NSLocalizedString(@"@Contacts requires access to your Twitter account so we can retrieve information about your new contact from Twitter", @"Pre-approval message for Twitter");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertController __weak *weakAlert = alert;
    
    UIAlertAction *allow = [UIAlertAction actionWithTitle:@"Allow access to Twitter" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self setUserDefault:kUserDefaultTwitterPreApprovalDialogHasBeenPresented to:YES];
                                                              [self setUserDefault:kUserDefaultTwitterApproved to:YES];
                                                              [self getUserInfo:_twitterName];
                                                          }];

    UIAlertAction *noTwitter = [UIAlertAction actionWithTitle:@"I don’t have a Twitter account" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
                                                      [weakAlert dismissViewControllerAnimated:YES completion:nil];
                                                      [self setUserDefault:kUserDefaultTwitterPreApprovalDialogHasBeenPresented to:YES];
                                                      [self displayNoTwitterDialog];
                                                  }];

    UIAlertAction *deny = [UIAlertAction actionWithTitle:@"Do NOT allow access to Twitter" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
                                                      [weakAlert dismissViewControllerAnimated:YES completion:nil];
                                                      [self setUserDefault:kUserDefaultTwitterPreApprovalDialogHasBeenPresented to:YES];
                                                      [self displayDeniedDialog];
                                                  }];
    // The order in which the buttons are added is the order in which they are displayed
    // Last button added will be highlighted as the default
    [alert addAction:allow];
    [alert addAction:noTwitter];
    [alert addAction:deny];

    return alert;
}

/**
 *  Formats and displays an alert for the user if they say they do not have a Twitter account
 *
 *  @since 1.0
 */
- (void)displayNoTwitterDialog {
    NSString *noTwitterMessage = [NSString stringWithFormat:NSLocalizedString(@"To retrieve information about @%@, you must have a Twitter account\n\n You can add a new or existing Twitter account in Settings", @"Title for pre-approval dialog"), _twitterName];
    NSString *noTwitterTitle = NSLocalizedString(@"@Contacts Requires a Twitter Account", @"Title for No Twitter Account message");
    UIAlertController *noTwitterAlert = [self basicAlert:noTwitterMessage title:noTwitterTitle];
    [_delegate displayAlert:noTwitterAlert];
}

/**
 *  Formats and displays an alert for the user if they deny access to their Twitter account
 *
 *  @since 1.0
 */
- (void)displayDeniedDialog {
    NSString *deniedMessage = [NSString stringWithFormat:NSLocalizedString(@"Without a Twitter account, we will not be able to retrieve information about @%@", @"Title for pre-approval dialog"), _twitterName];
    NSString *deniedTitle = NSLocalizedString(@"Access to Twitter Denied", @"Title for Access to Twitter Denied message");
    UIAlertController *noTwitterAlert = [self basicAlert:deniedMessage title:deniedTitle];
    [_delegate displayAlert:noTwitterAlert];
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
 *  Gets user default value for kUserDefaultTwitterApproved
 *
 *  @return User default value for kUserDefaultTwitterApproved
 *
 *  @since 1.0
 */
- (BOOL)isApproved {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL result = [defaults boolForKey:kUserDefaultTwitterApproved];
    
    return result;
}

/**
 *  Gets user default value for kUserDefaultTwitterPreApprovalDialogHasBeenPresented
 *
 *  @return User default value for kUserDefaultTwitterPreApprovalDialogHasBeenPresented
 *
 *  @since 1.0
 */
- (BOOL)isPreApprovedPresented {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL result = [defaults boolForKey:kUserDefaultTwitterPreApprovalDialogHasBeenPresented];
    
    return result;
}

/**
 *  Gets user default value for kUserDefaultTwitterNoTwitterAccount
 *
 *  @return User default value for kUserDefaultTwitterNoTwitterAccount
 *
 *  @since 1.0
 */
- (BOOL)isNoTwitterAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL result = [defaults boolForKey:kUserDefaultTwitterNoTwitterAccount];
    
    return result;
}

/**
 *  Gets user default value for kUserDefaultTwitterDenied
 *
 *  @return User default value for kUserDefaultTwitterDenied
 *
 *  @since 1.0
 */
- (BOOL)isDenied {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL result = [defaults boolForKey:kUserDefaultTwitterDenied];
    
    return result;
}

/**
 *  Generic setter for user defaults
 *
 *  @param key   Key to set
 *  @param value Value to set for the key
 *
 *  @since 1.0
 */
- (void)setUserDefault:(NSString *)key toValue:(id)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}

/**
 *  Generic setter for user defaults for BOOL values
 *
 *  @param key   Key to set
 *  @param value YES/NO
 *
 *  @since 1.0
 */
- (void)setUserDefault:(NSString *)key to:(BOOL)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:key];
    [defaults synchronize];
}

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
    BOOL dialogHasBeenPresented = [defaults boolForKey:kUserDefaultTwitterPreApprovalDialogHasBeenPresented];
    
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
    BOOL userDeniedPermission = [defaults boolForKey:kUserDefaultUserDeniedPermissionToTwitter];
    
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
    BOOL userHasNoAccount = [defaults boolForKey:kUserDefaultUserHasNoTwitterAccount];
    
    return userHasNoAccount;
}

/*
 *  Returns the account store.
 *  If the account doesn't already exist, it is created.
 */
- (NSString *)identifier {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *identifier = [defaults valueForKey:kUserDefaultTwitterAccount];
    
    return identifier;
}

/*
 *  Returns the account store.
 *  If the account doesn't already exist, it is created.
 */
- (void)setDefaultTwitterAccount:(NSString *)identifier {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:identifier forKey:kUserDefaultTwitterAccount];
    
}

/*
 *  Returns the default Twitter account to use (or nil if no Twitter account is set up)
 *
 */
- (ACAccount *)defaultTwitterAccount {
//    ACAccountStore *store = [self accountStore];
//    NSString *identifier = [self identifier];
//    ACAccountType *accountType = [self accountType];
//    ACAccount *account = [self twitterAccountWithIdentifier:identifier];
//    
//    if (account) {
//        return account;
//    } else {
//        NSArray *arrayOfAccounts = [store accountsWithAccountType:accountType];
//        ACAccount *account;
//
//        if ([arrayOfAccounts count] == 1) {
//            // Only one Twitter account is set up in Settings; make it the default
//            account = (ACAccount *)arrayOfAccounts[0];
//            NSString *identifier = [account identifier];
//            [self setDefaultTwitterAccount:identifier];
//            
//            return account;
//        }
//        
//        if ([arrayOfAccounts count] > 0) {
//            account = (ACAccount *) [arrayOfAccounts firstObject];
//            NSArray *accountIdentifiers = [self arrayOfAccountIdentifiers:arrayOfAccounts];
//            account = [self askForDefaultTwitterAccount:accountIdentifiers];
//            NSString *identifier = [account identifier];
//            [self setDefaultTwitterAccount:identifier];
//            
//            return account;
//        }
//    }

    return nil;

}

/**
 *  Returns the specific Twitter account for identifier
 *
 *  @param identifier Unique identifier for the Twitter account
 *
 *  @return The specified Twitter account
 *
 *  @since 1.0
 */
- (ACAccount *)twitterAccountWithIdentifier:(NSString *)identifier {
    ACAccountStore *store = [self accountStore];
    ACAccount *account = [store accountWithIdentifier:identifier];
    
    return account;
}

/**
 *  Gets a list of all the account identifiers for a set of accounts
 *
 *  @param arrayOfAccounts This will always be an array of all the Twitter accounts the user has set up
 *
 *  @return Array of all the account identifiers
 *
 *  @since 1.0
 */
- (NSArray *)arrayOfAccountIdentifiers:(NSArray *)arrayOfAccounts {
    NSMutableArray *identifierArray = [NSMutableArray new];

    for (ACAccount *account in arrayOfAccounts) {
        NSString *identifier = [account identifier];
        [identifierArray addObject:identifier];
    }
    NSArray *arrayOfAccountIdentifiers = [NSArray arrayWithArray:identifierArray];

    return arrayOfAccountIdentifiers;
}

/**
 *  Asks user which of their multiple Twitter accounts would they like to use (to Follow contacts)
 *
 *  @param arrayOfAccountIdentifiers Unique identifiers for each of the accounts the user has set up
 *
 *  @return The Twitter account the user has selected as their default account
 *
 *  @since 1.0
 */
- (ACAccount *)askForDefaultTwitterAccount:(NSArray *)arrayOfAccountIdentifiers {
    // TODO Present account identifiers and allow user to select one. Return it as the default
    
    // *** Replace this block with actual code ***
    NSString *defaultIdentifier = (NSString *)[arrayOfAccountIdentifiers lastObject];
    ACAccount *defaultAccount = [self twitterAccountWithIdentifier:defaultIdentifier];
    
    // *** End of replacement block ***
    
    return defaultAccount; // placeholder
}

@end


