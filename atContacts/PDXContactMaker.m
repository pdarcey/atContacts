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

- (void)petTapped:(NSDictionary *)personData {
    
    CFIndex authorisationStatus = [self getAuthorisationStatus];
    
    if (authorisationStatus == kABAuthorizationStatusDenied ||
        authorisationStatus == kABAuthorizationStatusRestricted){
            [self displayCantAddContactAlert];
            NSLog(@"Denied");
    } else if (authorisationStatus == kABAuthorizationStatusAuthorized){
            NSLog(@"Authorized");
        [self addToContacts:personData];
    } else {
        // authorisationStatus == kABAuthorizationStatusNotDetermined
        NSLog(@"Not determined");
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                [self displayCantAddContactAlert];
                return;
            }
            [self addToContacts:personData];
        });
    }
}

- (void)displayCantAddContactAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
//        UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
//        [cantAddContactAlert show];
    });
}

- (void)checkForExistingContact:(ABAddressBookRef)addressBookRef firstName:(NSString *)firstName person:(ABRecordRef)person {
    NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    for (id record in allContacts){
        ABRecordRef thisContact = (__bridge ABRecordRef)record;
        if (CFStringCompare(ABRecordCopyCompositeName(thisContact),
                            ABRecordCopyCompositeName(person), 0) == kCFCompareEqualTo){
            //The contact already exists!
//            UIAlertView *contactExistsAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"There can only be one %@", petFirstName] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [contactExistsAlert show];
            return;
        }
    }
}

- (void)addToContacts:(NSDictionary *)personData {
    NSString *firstName = [personData valueForKey:@"firstName"];
    NSString *lastName = [personData valueForKey:@"lastName"];
    NSString *twitterName = [personData valueForKey:@"twitterName"];
    NSData *imageData = [personData valueForKey:@"imageData"];
    
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
    ABRecordRef person = ABPersonCreate();
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFStringRef)firstName, nil);
    ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFStringRef)lastName, nil);
    
    ABMutableMultiValueRef twitterID = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(twitterID, (__bridge CFStringRef)twitterName, kABPersonSocialProfileServiceTwitter, NULL);
    ABRecordSetValue(person, kABPersonSocialProfileProperty, twitterID, nil);
    
    ABPersonSetImageData(person, (__bridge CFDataRef)imageData, nil);
    ABAddressBookAddRecord(addressBookRef, person, nil);
    
    [self checkForExistingContact:addressBookRef firstName:firstName person:person];
    
    ABAddressBookSave(addressBookRef, nil);
//    UIAlertView *contactAddedAlert = [[UIAlertView alloc]initWithTitle:@"Contact Added" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [contactAddedAlert show];
}


@end
