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

- (CFIndex)getAuthorisationStatus {
    CFIndex authorisationStatus = ABAddressBookGetAuthorizationStatus();
    
    return authorisationStatus;
}

- (void)addToContacts:(NSDictionary *)personData {
    
    CFIndex authorisationStatus = [self getAuthorisationStatus];
    
    if (authorisationStatus == kABAuthorizationStatusDenied ||
        authorisationStatus == kABAuthorizationStatusRestricted){
            [self displayCantAddContactAlert];
            NSLog(@"Denied");
    } else if (authorisationStatus == kABAuthorizationStatusAuthorized){
            NSLog(@"Authorized");
        [self makeContact:personData];
    } else {
        // authorisationStatus == kABAuthorizationStatusNotDetermined
        NSLog(@"Not determined");
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                [self displayCantAddContactAlert];
                return;
            }
            [self makeContact:personData];
        });
    }
}

- (void)displayCantAddContactAlert {
    [_delegate displayErrorMessage:NSLocalizedString(@"Can't add contact", @"Can't add a contact error alert")];
}

- (BOOL)checkForExistingContact:(ABAddressBookRef)addressBookRef person:(ABRecordRef)person {
    NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    for (id record in allContacts){
        ABRecordRef thisContact = (__bridge ABRecordRef)record;
        if (CFStringCompare(ABRecordCopyCompositeName(thisContact),
                            ABRecordCopyCompositeName(person), 0) == kCFCompareEqualTo){
            //The contact already exists!
            NSLog(@"Person already exists!");
            NSString *name = (__bridge NSString *)ABRecordCopyCompositeName(person);
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%@ is already in your Contacts", @"Tried to add a duplicate to Contacts"), name];
            [_delegate displayErrorMessage:message];
            return YES;
        }
    }
    return NO;
}

- (void)makeContact:(NSDictionary *)personData {
    NSString *firstName = [personData valueForKey:@"firstName"];
    NSString *lastName = [personData valueForKey:@"lastName"];
    NSString *twitterName = [personData valueForKey:@"twitterName"];
    NSString *emailAddress = [personData valueForKey:@"emailAddress"];
    NSString *phoneNumber = [personData valueForKey:@"phoneNumber"];
    NSString *wwwAddress = [personData valueForKey:@"wwwAddress"];
    NSString *twitterDescription = [personData valueForKey:@"twitterDescription"];
    NSData *photoData = [personData valueForKey:@"photoData"];
    
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
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
    ABAddressBookAddRecord(addressBookRef, person, nil);
    
    if (![self checkForExistingContact:addressBookRef person:person]) {
        ABAddressBookSave(addressBookRef, nil);
        [_delegate newContactMade:YES];
    };
    
}

// Required for protocol
- (void)newContactMade:(BOOL)success {
    
}

- (void)displayErrorMessage:(NSString *)message {
    
}


@end
