//
//  atContactsTests.m
//  atContactsTests
//
//  Created by Paul Darcey on 27/08/2014.
//  © 2014 Paul Darcey. All rights reserved.
//

@import UIKit;
@import XCTest;
#import "PDXTwitterCommunicator.h"
#import "PDXTwitterCommunicator+TestExtensions.h"

// Test data files
// These files are used to generate the NSData which is expected by PDXTwitterCommunicator
static NSString * const kTestDataUsersLookup = @"testUsersLookup";
static NSString * const kTestDataUsersSearch = @"testUsersSearch";
static NSString * const kTestDataFriendshipsCreateYES = @"testFriendshipsCreateYES";
static NSString * const kTestDataFriendshipsCreateNO = @"testFriendshipsCreateNO";
static NSString * const kTestDataFriendshipsLookupFollowing = @"testFriendshipsLookupFollowing";
static NSString * const kTestDataFriendshipsLookupNotFollowing = @"testFriendshipsLookupNotFollowing";

@interface PDXTwitterCommunicatorTests : XCTestCase

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

/**
 *  Convenience method that will read in a text file, turn it into NSData, and de-serialize the data 
 *  using NSJSONSerialization, just like the data being returned from Twitter
 *
 *  @param fileName The name of the file of test data to use
 *
 *  @return A dictionary of JSON data that has been de-serialized by NSJSONSerialization
 *
 *  @since 1.0
 */
- (NSDictionary *)getTestData:(NSString *)fileName {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    return jsonDict;
}

/**
 *  Tests the parsing algorithm for data from a Users/Lookup request from Twitter
 *
 *  @since 1.0
 */
- (void)testParseUsersLookup {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = [self getTestData:kTestDataUsersLookup];
    NSDictionary *expectedResults = @{ kPersonFirstName         : @"Twitter",
                                       kPersonLastName          : @"API",
                                       kPersonTwitterName       : @"@twitterapi",
                                       kPersonIdString          : @"6253282",
                                       kPersonFollowing         : [NSNumber numberWithBool:YES],
                                       kPersonEmailAddress      : @"",
                                       kPersonPhoneNumber       : @"",
                                       kPersonWwwAddress        : @"http://dev.twitter.com",
                                       kPersonTwitterDescription : @"The Real Twitter API. I tweet about API changes, service issues and happily answer questions about Twitter and our API. Don't get an answer? It's on my website.",
                                       kPersonPhotoURL          : @"http://a0.twimg.com/profile_images/2284174872/7df3h38zabcvjylnyfe3_normal.png",
                                       };
    NSDictionary *results = [twitter parseUsersLookup:data];
    XCTAssertEqualObjects(results, expectedResults, @"Dictionary not correctly parsed:\nExpected results = %@\n\nActual results = %@\n\n", expectedResults, results);

}

/**
 *  Tests method for splitting nameString into firstName and lastName when nameString is one word
 *
 *  @since 1.0
 */
- (void)testSplitNameOneWord {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSString *name = @"David";
    NSDictionary *result = [twitter splitName:name];
    NSDictionary *expectedResult = @{ kPersonFirstName : @"David", kPersonLastName : @"" };
    XCTAssertEqualObjects(result, expectedResult, @"Dictionary not correctly parsed");
}

/**
 *  Tests method for splitting nameString into firstName and lastName when nameString is two words
 *
 *  @since 1.0
 */
- (void)testSplitNameTwoWords {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSString *name = @"David Smith";
    NSDictionary *result = [twitter splitName:name];
    NSDictionary *expectedResult = @{ kPersonFirstName : @"David", kPersonLastName : @"Smith" };
    XCTAssertEqualObjects(result, expectedResult, @"Dictionary not correctly parsed");
}

/**
 *  Tests method for splitting nameString into firstName and lastName when nameString is more than two words
 *
 *  @since 1.0
 */
- (void)testSplitNameMultiWords {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSString *name = @"David van der Laar";
    NSDictionary *result = [twitter splitName:name];
    NSDictionary *expectedResult = @{ kPersonFirstName : @"David", kPersonLastName : @"van der Laar" };
    XCTAssertEqualObjects(result, expectedResult, @"Dictionary not correctly parsed");
}

/**
 *  Tests the parsing algorithm for response data from a Friendships/Create PUT request to Twitter
 *
 *  @since 1.0
 */
- (void)testParseFriendshipsCreateYES {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = [self getTestData:kTestDataFriendshipsCreateYES];
    
    BOOL result = [twitter parseFriendshipsCreate:data];
    
    XCTAssertTrue(result, @"Not parsing results from Friendship Create correctly");

}

/**
 *  Tests the speed of parsing response data from a Friendships/Create PUT request to Twitter
 *
 *  @since 1.0
 */
- (void)testParseFriendshipsCreateSpeed {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = [self getTestData:kTestDataFriendshipsCreateYES];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        [twitter parseFriendshipsCreate:data];
    }];
    
}

/**
 *  Tests the parsing algorithm for response data from a Friendships/Create PUT request to Twitter
 *
 *  @since 1.0
 */
- (void)testParseFriendshipsCreateNO {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = [self getTestData:kTestDataFriendshipsCreateNO];
    
    BOOL result = [twitter parseFriendshipsCreate:data];
    
    XCTAssertFalse(result, @"Not parsing results from Friendship Create correctly");
    
}

/**
 *  Tests the parsing algorithm for data from a Friendships/Lookup request from Twitter
 *
 *  @since 1.0
 */
- (void)testParseFriendshipsLookupYES {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = [self getTestData:kTestDataFriendshipsLookupFollowing];
    
    BOOL result = [twitter parseFriendshipsLookup:data];
    
    XCTAssertTrue(result, @"Not parsing results from Users Create correctly");
    
}

/**
 *  Tests the parsing algorithm for data from a Friendships/Lookup request from Twitter
 *
 *  @since 1.0
 */
- (void)testParseFriendshipsLookupNO {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = [self getTestData:kTestDataFriendshipsLookupNotFollowing];
    
    BOOL result = [twitter parseFriendshipsLookup:data];
    
    XCTAssertFalse(result, @"Not parsing results from Friendship Create correctly");
    
}

/**
 *  Tests the parsing algorithm for data from a Users/Search request from Twitter
 *
 *  @since 1.0
 */
- (void)testParsePersonalURL {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = [self getTestData:kTestDataUsersSearch];
    
    NSString *result = [twitter parsePersonalURL:data];
    NSString *expectedResult = kBlankString;
    
    XCTAssertEqualObjects(result, expectedResult, @"Expected \"%@\" but got \"%@\"", expectedResult, result);
}

/**
 *  Tests extracting a specific type of data from a Users/Lookup request from Twitter
 *
 *  @since 1.0
 */
- (void)testExtractString {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    NSDictionary *data = [self getTestData:kTestDataUsersLookup];

    NSString *result = [twitter extractString:kTwitterParameterIDStr from:data];
    NSString *expectedResult = @"6253282";
    
    XCTAssertEqualObjects(result, expectedResult, @"Expected \"%@\" but got \"%@\"", expectedResult, result);

}

/**
 *  Tests that, if accountStore was nil, one is created and returned
 *
 *  @since 1.0
 */
- (void)testAccountStoreWasNil {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    twitter.accountStore = nil;
    
    ACAccountStore *result = [twitter accountStore];
    
    XCTAssertNotNil(result, "Should *always* return an ACAccountStore object");
}

/**
 *  Tests that, if accountStore exists, that one is returned
 *
 *  @since 1.0
 */
- (void)testAccountStoreExists {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    ACAccountStore *account = [[ACAccountStore alloc] init];
    twitter.accountStore = account;
    
    ACAccountStore *result = [twitter accountStore];
    
    XCTAssertEqualObjects(result, account, @"Should return existing ACAccountStore if one exists");
}

/**
 *  Tests that, if twitterType was nil, one is created and returned
 *
 *  @since 1.0
 */
- (void)testAccountTypeWasNil {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    twitter.twitterType = nil;
    
    ACAccountType *result = [twitter accountType];
    
    XCTAssertNotNil(result, "Should *always* return an ACAccountType object");
}

/**
 *  Tests that, if twitterType exists, that one is returned
 *
 *  @since <#version number#>
 */
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

@end
