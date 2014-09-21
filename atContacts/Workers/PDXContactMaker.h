//
//  PDXContactMaker.h
//  atContacts
//
//  Created by Paul Darcey on 13/09/2014.
//  © 2014 Paul Darcey. All rights reserved.
//

@import Foundation;
@import AddressBook;
#import "PDXConstants.h"

#pragma mark - Protocol

@protocol PDXContactMakerDelegate <NSObject>

@required
- (void)newContactMade:(BOOL)success;
- (void)displayErrorMessage:(NSString *)message;

@end

#pragma make - Interface

@interface PDXContactMaker : NSObject

@property (nonatomic, assign) id < PDXContactMakerDelegate > delegate;

- (void)addToContacts:(NSDictionary *)personData;
- (BOOL)isInContacts:(NSDictionary *)personData;

@end
