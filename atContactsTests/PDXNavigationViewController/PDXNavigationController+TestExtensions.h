//
//  PDXNavigationController+TestExtensions.h
//  @Contacts
//
//  Created by Paul Darcey on 16/10/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

@import Foundation;

@interface PDXNavigationController (TestExtensions)

- (void)displayInfo:(NSDictionary *)data;
- (void)test:(NSDictionary *)data;
- (void)displayErrorMessage:(NSString *)message;
- (void)displayAlert:(UIAlertController *)alert;
- (UILabel *)makeErrorMessage:(NSString *)message;

@end
