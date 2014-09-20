//
//  PDXContactMakerTests.m
//  atContacts
//
//  Created by Paul Darcey on 14/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

@import UIKit;
@import XCTest;
#import "PDXContactMaker.h"
#import "PDXContactMaker+TestExtensions.h"

@interface PDXContactMakerTests : XCTestCase

@end

@implementation PDXContactMakerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetAuthorisationStatus {
    
}

- (void)testDisplayCantAddContactAlert {
    
}

- (void)testCheckForExistingContact {
    
}

- (void)testMakeContact {
    
}

/**
 *  Tests that a person is correctly added to Contacts
 *
 *  @since 1.0
 */
- (void)testAddToContacts {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    CFIndex startPersonCount = ABAddressBookGetPersonCount(addressBook);
    
    PDXContactMaker *contactMaker = [PDXContactMaker new];
    NSDictionary *personData = @{ kPersonFirstName          : @"Test",
                                  kPersonLastName           : [NSString stringWithFormat:@"Else %@", [NSDate date]],
                                  kPersonTwitterName        : @"@abcdefg",
                                  kPersonEmailAddress       : @"email@test.com",
                                  kPersonPhoneNumber        : @"+38512345678",
                                  kPersonWwwAddress         : @"www.test.com",
                                  kPersonTwitterDescription : @"Test description"
                                  };
    
    [contactMaker addToContacts:personData];
    
    CFIndex endPersonCount = ABAddressBookGetPersonCount(addressBook);
    
    XCTAssertEqual(endPersonCount, startPersonCount + 1, @"\nStarted with %li entries, ended with %li (expected %li)\n", startPersonCount, endPersonCount, startPersonCount + 1);

}

/**
 *  Monitors the speed of the code which adds a person to Contacts
 *
 *  @since 1.0
 */
- (void)testAddToContactsSpeed {
//    // This is an example of a performance test case.

    PDXContactMaker *contactMaker = [PDXContactMaker new];
    NSDictionary *personData = @{ kPersonFirstName          : @"Test",
                                  kPersonLastName           : [NSString stringWithFormat:@"Else %@", [NSDate date]],
                                  kPersonTwitterName        : @"@abcdefg",
                                  kPersonEmailAddress       : @"email@test.com",
                                  kPersonPhoneNumber        : @"+38512345678",
                                  kPersonWwwAddress         : @"www.test.com",
                                  kPersonTwitterDescription : @"Test description"
                                  };

    [self measureBlock:^{
        // Put the code you want to measure the time of here.
       [contactMaker addToContacts:personData];
    }];

}

@end
