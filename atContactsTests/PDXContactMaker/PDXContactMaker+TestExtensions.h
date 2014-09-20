//
//  PDXContactMaker+TestExtensions.h
//  atContacts
//
//  Created by Paul Darcey on 14/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDXContactMaker (TestExtensions)

/**
 *  Exposes methods within PDXContactMaker which would otherwise not be available for individual testing
 *
 *  The following are only exposed for testing
 *
 *  @since 1.0
 */

- (CFIndex)getAuthorisationStatus;
- (void)displayCantAddContactAlert;
- (void)checkForExistingContact:(ABAddressBookRef)addressBookRef firstName:(NSString *)firstName person:(ABRecordRef)person;
- (void)makeContact:(NSDictionary *)personData;

@end
