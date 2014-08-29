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
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
         if (granted == YES) {
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
             
             if ([arrayOfAccounts count] > 0) {
                 ACAccount *twitterAccount =
                 [arrayOfAccounts lastObject];
                 
                 NSURL *requestURL = [NSURL URLWithString: @"https://api.twitter.com/1.1/users/lookup.json"];
                 
                 NSDictionary *parameters = @{@"screen_name" : name};
                 
                 SLRequest *postRequest = [SLRequest
                                           requestForServiceType:SLServiceTypeTwitter
                                           requestMethod:SLRequestMethodGET
                                           URL:requestURL parameters:parameters];
                 
                 postRequest.account = twitterAccount;
                 
                 [postRequest performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                      _twitterData = [NSJSONSerialization
                                         JSONObjectWithData:responseData
                                         options:NSJSONReadingMutableLeaves
                                         error:&error];
 
                      if (_twitterData != nil) {
                          [self parseResults];
                      }
                  }];
             }
         } else {
             // Handle failure to get account access
         }
     }];
}

- (void)sendRequest {
    // Set up request
    NSArray *accounts = [_accountStore accountsWithAccountType:_twitterType];
    SLRequest *request = [self createRequest];
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
    //
    
    [request performRequestWithHandler:requestHandler];
}

/**
 *  Checks if the user has authorised access to their Twitter account
 *
 *  @since 1.0
 */
- (void)checkForTwitterAccess {

    // First, check user defaults
    
    // If necessary, show pre-access dialog, to prepare user for access request
    
    // Request system access to user's Twitter account
    _accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:
                                  ACAccountTypeIdentifierTwitter];
    
    [_accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted == YES) {
            
            NSArray *arrayOfAccounts = [_accountStore accountsWithAccountType:accountType];
            
            if ([arrayOfAccounts count] > 0) {
                
                ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                
                SLRequest *request = [self createRequest];
                
                request.account = twitterAccount;
                
                [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
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
                 }];
            }
        }
    }];
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
- (SLRequest *)createRequest {
    // We are using version 1.1 of the Twitter API. This may need to be changed to whichever version is currently appropriate.
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/lookup.json?screen_name=%@", _name];
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
    
    // Present results
}

@end
