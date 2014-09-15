//
//  PDXContactMaker.h
//  atContacts
//
//  Created by Paul Darcey on 13/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AddressBook;

@protocol PDXContactMakerDelegate <NSObject>
#pragma mark - Protocol

@required
- (void)newContactMade:(BOOL)success;

@end

@interface PDXContactMaker : NSObject

@property (nonatomic, assign) id < PDXContactMakerDelegate > delegate;

- (void)addToContacts:(NSDictionary *)personData;

@end
