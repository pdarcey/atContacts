//
//  PDXContactMaker.h
//  atContacts
//
//  Created by Paul Darcey on 13/09/2014.
//  © 2014 Paul Darcey. All rights reserved.
//

@import Foundation;
@import UIKit;
@import AddressBook;
#import "PDXConstants.h"

#pragma mark - Protocol

@protocol PDXContactMakerDelegate <NSObject>

@required
- (void)newContactMade:(BOOL)success;

@optional
- (void)displayErrorMessage:(NSString *)message;
- (void)displayAlert:(UIAlertController *)alert;

@end

// User Defaults
static NSString * const kUserDefaultContactsPreApprovalDialogHasBeenPresented = @"contactsPreApprovalDialogHasBeenPresented";

#pragma make - Interface

@interface PDXContactMaker : NSObject

@property (strong, nonatomic) NSDictionary *data;
@property (weak, nonatomic) id < PDXContactMakerDelegate > delegate;

- (void)addToContacts:(NSDictionary *)personData;
- (BOOL)isInContacts:(NSDictionary *)personData;

@end
