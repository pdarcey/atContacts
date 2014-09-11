//
//  atContactsTests.m
//  atContactsTests
//
//  Created by Paul Darcey on 27/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PDXTwitterCommunicator.h"
#import "PDXTwitterCommunicator+TestExtensions.h"

@interface PDXTwitterCommunicatorTests : XCTestCase

@property (strong, nonatomic) NSDictionary *data;

@end

@implementation PDXTwitterCommunicatorTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testJSONData" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    _data = jsonDict;
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParseUsersLookup {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = _data;
    NSDictionary *expectedResults = @{ @"firstName" : @"Twitter",
                                       @"lastName" : @"API",
                                       @"twitterName" : @"@twitterapi",
                                       @"idString" : @"6253282",
                                       @"emailAddress" : @"",
                                       @"phoneNumber" : @"",
                                       @"wwwAddress" : @"http://dev.twitter.com",
                                       @"twitterDescription" : @"The Real Twitter API. I tweet about API changes, service issues and happily answer questions about Twitter and our API. Don't get an answer? It's on my website.",
                                       @"photoURL" : @"http://a0.twimg.com/profile_images/2284174872/7df3h38zabcvjylnyfe3_normal.png",
                                       };
    NSDictionary *results = [twitter parseUsersLookup:data];
    XCTAssertEqualObjects(results, expectedResults, @"Dictionary not correctly parsed:\nExpected results = %@\n\nActual results = %@\n\n", expectedResults, results);

}

- (void)testSplitNameOneWord {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSString *name = @"David";
    NSDictionary *result = [twitter splitName:name];
    NSDictionary *expectedResult = @{ @"firstName" : @"David", @"lastName" : @"" };
    XCTAssertEqualObjects(result, expectedResult, @"Dictionary not correctly parsed");
}

- (void)testSplitNameTwoWords {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSString *name = @"David Smith";
    NSDictionary *result = [twitter splitName:name];
    NSDictionary *expectedResult = @{ @"firstName" : @"David", @"lastName" : @"Smith" };
    XCTAssertEqualObjects(result, expectedResult, @"Dictionary not correctly parsed");
}

- (void)testSplitNameMultiWords {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSString *name = @"David van der Laar";
    NSDictionary *result = [twitter splitName:name];
    NSDictionary *expectedResult = @{ @"firstName" : @"David", @"lastName" : @"van der Laar" };
    XCTAssertEqualObjects(result, expectedResult, @"Dictionary not correctly parsed");
}

- (void)testParseFriendshipsCreate {
    
}

- (void)testParseFriendshipsLookup {
    
}

- (void)testParsePersonalURL {
    
}

- (void)testExtractString {
    
}

- (void)testAccountStore {
    
}

- (void)testAccountType {
    
}

- (void)testDialogHasBeenPresented {
    
}

- (void)testUserDeniedPermission {
    
}

- (void)testUserHasNoAccount {
    
}

- (void)testIdentifier {
    
}

- (void)testSetDefaultTwitterAccount {
    
}

- (void)testDefaultTwitterAccount; {
    
}

- (void)testTwitterAccountWithIdentifier {
    
}

- (void)testArrayOfAccountIdentifiers {
    
}

- (void)testAskForDefaultTwitterAccount {
    
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
