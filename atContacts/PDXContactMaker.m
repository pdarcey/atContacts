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
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Display alert view: Can't add contact");
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
            NSLog(@"Person already exists!");
//            UIAlertView *contactExistsAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"There can only be one %@", petFirstName] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [contactExistsAlert show];
            return;
        }
    }
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
    ABMultiValueAddValueAndLabel(twitterID, (__bridge CFStringRef)twitterName, kABPersonSocialProfileServiceTwitter, NULL);
    ABRecordSetValue(person, kABPersonSocialProfileProperty, twitterID, nil);
    
    ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(email, (__bridge CFStringRef)emailAddress, (__bridge CFStringRef)@"email", NULL);
    ABRecordSetValue(person, kABPersonEmailProperty, email, nil);

    ABMutableMultiValueRef phone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phone, (__bridge CFStringRef)phoneNumber, kABPersonPhoneIPhoneLabel, NULL);
    ABRecordSetValue(person, kABPersonPhoneProperty, phone, nil);

    ABMutableMultiValueRef web = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(web, (__bridge CFStringRef)wwwAddress, kABPersonHomePageLabel, NULL);
    ABRecordSetValue(person, kABPersonURLProperty, web, nil);

    
    ABPersonSetImageData(person, (__bridge CFDataRef)photoData, nil);
    ABAddressBookAddRecord(addressBookRef, person, nil);
    
    [self checkForExistingContact:addressBookRef firstName:firstName person:person];
    
    ABAddressBookSave(addressBookRef, nil);
    NSLog(@"Display alert view: Contact added");
//    UIAlertView *contactAddedAlert = [[UIAlertView alloc]initWithTitle:@"Contact Added" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [contactAddedAlert show];
}


@end
