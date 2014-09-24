//
//  PDXContactMaker.m
//  atContacts
//
//  Created by Paul Darcey on 13/09/2014.
//  © 2014 Paul Darcey. All rights reserved.
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
    
    if ([self isPreApprovedPresented]) {
        CFIndex authorisationStatus = [self getAuthorisationStatus];
        
        if (authorisationStatus == kABAuthorizationStatusDenied ||
            authorisationStatus == kABAuthorizationStatusRestricted) {
            NSString *name = [NSString stringWithFormat:@"%@ %@", [personData valueForKey:kPersonFirstName], [personData valueForKey:kPersonLastName]];
            name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *message;

            if (authorisationStatus == kABAuthorizationStatusDenied) {
                message = [NSString stringWithFormat:NSLocalizedString(@"Cannot add %@ to contacts as you have denied access to @Contacts. This can be changed in Settings", @"User has denied access to Contacts"), name];
            } else {
                message = [NSString stringWithFormat:NSLocalizedString(@"Cannot add %@ to contacts as @Contacts does not have permission. See your administrator", @"Administrator has restricted access to Contacts"), name];
            }
            UIAlertController *initialDialog = [self errorDialog:message title:nil];
            [_delegate displayAlert:initialDialog];
        } else if (authorisationStatus == kABAuthorizationStatusAuthorized){
            NSLog(@"Authorized");
            [self makeContact:personData];
        } else {
            // authorisationStatus == kABAuthorizationStatusNotDetermined
            NSLog(@"Not determined");
            ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
                if (!granted) {
                    NSString *message = [NSString stringWithFormat:@"Error accessing Contacts: %ld - %@", CFErrorGetCode(error), CFErrorCopyDescription(error)];
                    NSLog(@"%@", message);
                    UIAlertController *initialDialog = [self errorDialog:message title:nil];
                    [_delegate displayAlert:initialDialog];
                    return;
                }
                [self makeContact:personData];
            });
        }
    } else {
        _data = personData;
        UIAlertController *initialDialog = [self preApprovalDialog];
        [_delegate displayAlert:initialDialog];
    }
}

- (BOOL)isPreApprovedPresented {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL result = [defaults boolForKey:kUserDefaultContactsPreApprovalDialogHasBeenPresented];
    
    return result;
}

- (UIAlertController *)preApprovalDialog {
    NSString *title = NSLocalizedString(@"Access to Contacts", @"Title for contacts pre-approval dialog");
    NSString *message = NSLocalizedString(@"@Contacts requires access to your Contacts so we can save information about your new contact from Twitter", @"Pre-approval message for Contacts");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertController __weak *weakAlert = alert;
    
    UIAlertAction *allow = [UIAlertAction actionWithTitle:@"Allow access to Contacts" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
                                                      [weakAlert dismissViewControllerAnimated:YES completion:nil];
                                                      [self setUserDefault:kUserDefaultContactsPreApprovalDialogHasBeenPresented to:YES];
                                                      [self addToContacts:_data];
                                                  }];
    
    
    UIAlertAction *deny = [UIAlertAction actionWithTitle:@"Do NOT allow access to Contacts" style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
                                                     [weakAlert dismissViewControllerAnimated:YES completion:nil];
                                                     [self setUserDefault:kUserDefaultContactsPreApprovalDialogHasBeenPresented to:YES];
                                                 }];
    // The order in which the buttons are added is the order in which they are displayed
    // Last button added will be highlighted as the default
    [alert addAction:allow];
    [alert addAction:deny];
    
    return alert;
}

- (UIAlertController *)errorDialog:(NSString *)message title:(NSString *)title {
    if (!title) {
        title = NSLocalizedString(@"Problem Accessing Contacts", @"Default title for contacts error dialog");
    }

    if (!message) {
        message = NSLocalizedString(@"There was an unexpected problem accessing contacts", @"Default message for contacts error dialog");
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertController __weak *weakAlert = alert;
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
                                                     [weakAlert dismissViewControllerAnimated:YES completion:nil];
                                                 }];
    
    [alert addAction:ok];
    
    return alert;
}

- (void)setUserDefault:(NSString *)key to:(BOOL)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:key];
    [defaults synchronize];
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
 *  Display a message to user that we can't add this person
 *
 *  @since 1.0
 */
- (void)displayCantAddContactAlert:(NSString *)message {
    [_delegate displayErrorMessage:NSLocalizedString(message, @"")];
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
    NSString *wwwAddress = [personData valueForKey:kPersonWebAddress];
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

@end
