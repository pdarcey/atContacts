//
//  PDXContactMaker+TestExtensions.h
//  atContacts
//
//  Created by Paul Darcey on 14/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDXContactMaker (TestExtensions)

- (CFIndex)getAuthorisationStatus;
- (void)displayCantAddContactAlert;
- (void)checkForExistingContact:(ABAddressBookRef)addressBookRef firstName:(NSString *)firstName person:(ABRecordRef)person;
- (void)makeContact:(NSDictionary *)personData;

@end
