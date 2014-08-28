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


- (void)findName:(NSString *)name {
    
    if ([self checkForTwitterAccess]) {
        [self sendRequest:name];
    }
}

- (void)sendRequest:(NSString *)name {
    // Update user defaults
    
    NSArray *accounts = [self.accountStore accountsWithAccountType:_twitterType];
    SLRequest *request = [self createRequest:name];
    [request setAccount:[accounts lastObject]];
    
    SLRequestHandler requestHandler =
    ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *postResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData
                                                options:NSJSONReadingMutableContainers
                                                  error:NULL];
                
                NSLog(@"[SUCCESS!] Received data: %@", postResponseData[@"id_str"]);
                _twitterData = postResponseData;
                [self parseResults];
            }
            else {
                NSLog(@"[ERROR] Server responded: status code %ld %@", (long)statusCode,
                      [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
            }
        }
        else {
            NSLog(@"[ERROR] An error occurred: %@", [error localizedDescription]);
        }
    };
    
    [request performRequestWithHandler:requestHandler];
}

/**
 *  Checks if the user has authorised access to their Twitter account
 *
 *  @since 1.0
 */
- (BOOL)checkForTwitterAccess {

    // First, check user defaults
    
    // If necessary, show pre-access dialog, to prepare user for access request
    
    // Request system access to user's Twitter account
    _accountStore = [[ACAccountStore alloc] init];

    BOOL __block accessGranted = NO;
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
    ^(BOOL granted, NSError *error) {
        if (granted) {
            // Update user defaults
            
            accessGranted = YES;
        }
        else {
            // Update user defaults
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
                  [error localizedDescription]);
            accessGranted = NO;
        }
    };
    return accessGranted;
}

/**
 *  Creates an SLRequest for Twitter's API v1.1 to search for a user given their user name (e.g. @twitter)
 *
 *  @param name The user's Twitter name, without the leading "@"
 *
 *  @return Returns a properly formatted SLRequest
 *
 *  @since 1.0
 */
- (SLRequest *)createRequest:(NSString *)name {
    // We are using version 1.1 of the Twitter API. This may need to be changed to whichever version is currently appropriate.
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/lookup.json?screen_name=%@", name];
    NSURL *url = [NSURL URLWithString:urlString];
    
    SLRequest *getRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:nil];

    return getRequest;
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
}

@end
