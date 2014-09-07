//
//  PDXNameFinder.h
//  atContacts
//
//  Created by Paul Darcey on 28/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

@import Foundation;
@import Accounts;
@import Social;
#import "AppDelegate.h"
#import "PDXTwitterCommunicator.h"

@interface PDXNameFinder : NSObject

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccountType *twitterType;
@property (nonatomic, strong) NSDictionary *twitterData;
@property (nonatomic, strong) NSString *name;

- (void)findName:(NSString *)name;
- (void)retrieveInformation;

@end
