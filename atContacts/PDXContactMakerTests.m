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

- (void)testAddToContacts {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    int startPersonCount = ABAddressBookGetPersonCount(addressBook);
    
    PDXContactMaker *contactMaker = [PDXContactMaker new];
    NSDictionary *personData = @{ @"firstName"    : @"Test",
                                  @"lastName"     : [NSString stringWithFormat:@"Else %@", [NSDate date]],
                                  @"twitterName"  : @"@abcdefg",
                                  @"emailAddress" : @"email@test.com",
                                  @"phoneNumber"  : @"+38512345678",
                                  @"wwwAddress"   : @"www.test.com",
                                  @"twitterDescription" : @"Test description"
                                  };
    
    [contactMaker addToContacts:personData];
    
    int endPersonCount = ABAddressBookGetPersonCount(addressBook);
    
    XCTAssertEqual(endPersonCount, startPersonCount + 1, @"\nStarted with %i entries, ended with %i (expected %i)\n", startPersonCount, endPersonCount, startPersonCount + 1);

}

@end
