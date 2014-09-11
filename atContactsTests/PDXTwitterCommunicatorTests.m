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

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSDictionary *)getTestData:(NSString *)fileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    return jsonDict;
}

- (void)testParseUsersLookup {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = [self getTestData:@"testUsersLookup"];
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

- (void)testParseFriendshipsCreateYES {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = [self getTestData:@"testFriendshipsCreateYES"];
    
    BOOL result = [twitter parseFriendshipsCreate:data];
    
    XCTAssertTrue(result, @"Not parsing results from Friendship Create correctly");

}

- (void)testParseFriendshipsCreateNO {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = [self getTestData:@"testFriendshipsCreateNO"];
    
    BOOL result = [twitter parseFriendshipsCreate:data];
    
    XCTAssertFalse(result, @"Not parsing results from Friendship Create correctly");
    
}

- (void)testParseFriendshipsLookupYES {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = [self getTestData:@"testFriendshipsLookupFollowing"];
    
    BOOL result = [twitter parseFriendshipsLookup:data];
    
    XCTAssertTrue(result, @"Not parsing results from Users Create correctly");
    
}

- (void)testParseFriendshipsLookupNO {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = [self getTestData:@"testFriendshipsLookupNotFollowing"];
    
    BOOL result = [twitter parseFriendshipsLookup:data];
    
    XCTAssertFalse(result, @"Not parsing results from Friendship Create correctly");
    
}

- (void)testParsePersonalURL {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = [self getTestData:@"testUsersSearch"];
    
    NSString *result = [twitter parsePersonalURL:data];
    NSString *expectedResult = @"";
    
    XCTAssertEqualObjects(result, expectedResult, @"Expected \"%@\" but got \"%@\"", expectedResult, result);
}

- (void)testExtractString {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = [self getTestData:@"testUsersLookup"];

    NSString *result = [twitter extractString:@"id_str" from:data];
    NSString *expectedResult = @"6253282";
    
    XCTAssertEqualObjects(result, expectedResult, @"Expected \"%@\" but got \"%@\"", expectedResult, result);

}

- (void)testAccountStoreWasNil {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    twitter.accountStore = nil;
    
    ACAccountStore *result = [twitter accountStore];
    
    XCTAssertNotNil(result, "Should *always* return an ACAccountStore object");
}

- (void)testAccountStoreExists {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    ACAccountStore *account = [[ACAccountStore alloc] init];
    twitter.accountStore = account;
    
    ACAccountStore *result = [twitter accountStore];
    
    XCTAssertEqualObjects(result, account, @"Should return existing ACAccountStore if one exists");
}

- (void)testAccountTypeWasNil {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    twitter.twitterType = nil;
    
    ACAccountType *result = [twitter accountType];
    
    XCTAssertNotNil(result, "Should *always* return an ACAccountType object");
}

- (void)testAccountTypeExists {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    ACAccountType *accountType = [[twitter accountStore] accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    twitter.twitterType = accountType;
    
    ACAccountType *result = [twitter accountType];
    
    XCTAssertEqualObjects(result, accountType, @"Should return existing ACAccountType if one exists");
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
