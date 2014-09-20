//
//  PDXContactMaker.m
//  atContacts
//
//  Created by Paul Darcey on 13/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXContactMaker.h"
@import AddressBook;

@implementation PDXContactMaker

/**
 *  Authorisation status for access to user's Contacts
 *
 *  @return Authorisation status. Possible values are:
 *     kABAuthorizationStatusNotDetermined,
 *     kABAuthorizationStatusRestricted,
 *     kABAuthorizationStatusDenied,
 *     kABAuthorizationStatusAuthorized
 *
 *  @since 1.0
 */
- (CFIndex)getAuthorisationStatus {
    CFIndex authorisationStatus = ABAddressBookGetAuthorizationStatus();
    
    return authorisationStatus;
}

/**
 *  Checks for authorised access to Contacts. If necessary asks for authorisation.
 *
 *  Then creates a person and adds them to Contats
 *
 *  @param personData Dictionary of info for the person to create
 *
 *  @since 1.0
 */
- (void)addToContacts:(NSDictionary *)personData {
    
    CFIndex authorisationStatus = [self getAuthorisationStatus];
    
    if (authorisationStatus == kABAuthorizationStatusDenied ||
        authorisationStatus == kABAuthorizationStatusRestricted) {
            [self displayCantAddContactAlert];
            NSLog(@"Denied");
    } else if (authorisationStatus == kABAuthorizationStatusAuthorized){
            NSLog(@"Authorized");
        [self makeContact:personData];
    } else {
        // authorisationStatus == kABAuthorizationStatusNotDetermined
        NSLog(@"Not determined");
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted) {
                [self displayCantAddContactAlert];
                return;
            }
            [self makeContact:personData];
        });
    }
}

/**
 *  Is this person already in Contacts?
 *
 *  @param personData Dictionary of info for the person to check for
 *
 *  @return YES if a person with the exact same name already exists; NO if not
 *
 *  @since 1.0
 */
- (BOOL)isInContacts:(NSDictionary *)personData {
    ABRecordRef person = [self makePerson:personData];
    
    return [self isExistingContact:person];
}

/**
 *  Display a message to user that we can't add this person
 *
 *  @since 1.0
 */
- (void)displayCantAddContactAlert {
    [_delegate displayErrorMessage:NSLocalizedString(@"Can't add contact", @"Can't add a contact error alert")];
}

/**
 *  Is this person already in Contacts?
 *
 *  @param person An ABRecordRef for the person
 *
 *  @return YES if a person with the exact same name already exists; NO if not
 *
 *  @since 1.0
 */
- (BOOL)isExistingContact:(ABRecordRef)person {
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
    NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);

    for (id record in allContacts) {
        ABRecordRef thisContact = (__bridge ABRecordRef)record;

        if (CFStringCompare(ABRecordCopyCompositeName(thisContact),
                            ABRecordCopyCompositeName(person), 0) == kCFCompareEqualTo) {

            return YES;
        }
    }

    return NO;
}

/**
 *  Turns a dictionary of person data into an ABRecordRef and saves it to Contacts if it is not a duplicate
 *
 *  @param personData Dictionary with the person's data
 *
 *  @since 1.0
 */
- (void)makeContact:(NSDictionary *)personData {
    ABRecordRef person = [self makePerson:personData];

    if (![self isExistingContact:person]) {
        [self saveContact:person];
    } else {
        //The contact already exists!
        NSString *name = (__bridge NSString *)ABRecordCopyCompositeName(person);
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%@ is already in your Contacts", @"Tried to add a duplicate to Contacts"), name];
        [_delegate displayErrorMessage:message];
    }
    
}

/**
 *  Turns a dictionary of person data into an ABRecordRef
 *
 *  @param personData Dictionary with the person's data
 *
 *  @return An ABRecordRef for the person
 *
 *  @since 1.0
 */
- (ABRecordRef)makePerson:(NSDictionary *)personData {
    NSString *firstName = [personData valueForKey:kPersonFirstName];
    NSString *lastName = [personData valueForKey:kPersonLastName];
    NSString *twitterName = [personData valueForKey:kPersonTwitterName];
    NSString *emailAddress = [personData valueForKey:kPersonEmailAddress];
    NSString *phoneNumber = [personData valueForKey:kPersonPhoneNumber];
    NSString *wwwAddress = [personData valueForKey:kPersonWwwAddress];
    NSString *twitterDescription = [personData valueForKey:kPersonTwitterDescription];
    NSData *photoData = [personData valueForKey:kPersonPhotoData];
    
    ABRecordRef person = ABPersonCreate();
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFStringRef)firstName, nil);
    ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFStringRef)lastName, nil);
    ABRecordSetValue(person, kABPersonNoteProperty, (__bridge CFStringRef)twitterDescription, nil);
    
    ABMutableMultiValueRef twitterID = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(twitterID, (__bridge CFTypeRef)
                            (@{ (NSString *)kABPersonSocialProfileServiceKey  : (NSString *)kABPersonSocialProfileServiceTwitter,
                                (NSString *)kABPersonSocialProfileUsernameKey : twitterName
                            }), kABPersonSocialProfileServiceTwitter, NULL);
    ABRecordSetValue(person, kABPersonSocialProfileProperty, twitterID, NULL);
    CFRelease(twitterID);
    
    ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(email, (__bridge CFStringRef)emailAddress, (__bridge CFStringRef)@"email", NULL);
    ABRecordSetValue(person, kABPersonEmailProperty, email, nil);
    CFRelease(email);

    ABMutableMultiValueRef phone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phone, (__bridge CFStringRef)phoneNumber, kABPersonPhoneIPhoneLabel, NULL);
    ABRecordSetValue(person, kABPersonPhoneProperty, phone, nil);
    CFRelease(phone);

    ABMutableMultiValueRef web = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(web, (__bridge CFStringRef)wwwAddress, kABPersonHomePageLabel, NULL);
    ABRecordSetValue(person, kABPersonURLProperty, web, nil);
    CFRelease(web);

    ABPersonSetImageData(person, (__bridge CFDataRef)photoData, nil);

    return person;
}

/**
 *  Saves a person to Contacts
 *
 *  @param person ABRecordRef for the person
 *
 *  @since 1.0
 */
- (void)saveContact:(ABRecordRef)person {
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
    ABAddressBookAddRecord(addressBookRef, person, nil);
    ABAddressBookSave(addressBookRef, nil);
    [_delegate newContactMade:YES];
}

// Required for protocol
- (void)newContactMade:(BOOL)success {
    
}

- (void)displayErrorMessage:(NSString *)message {
    
}

@end
