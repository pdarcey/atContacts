//
//  PDXInputVCTests.m
//  atContacts
//
//  Created by Paul Darcey on 12/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

@import UIKit;
@import XCTest;
#import "PDXInputViewController.h"
#import "PDXInputViewController+TestExtensions.h"


@interface PDXInputVCTests : XCTestCase

@property (strong, nonatomic) PDXInputViewController *inputVC;

@end

@implementation PDXInputVCTests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // Initialise view controller
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:kStoryboardMain bundle:nil];
    PDXInputViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:kStoryboardIdentifierInput];
    _inputVC = vc;

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRemoveHash {
    PDXInputViewController *inputVC = _inputVC;
    NSString *hashText = @"#hashtag";
    NSString *nonHashText = @"hashtag";
    NSString *expectedResult = @"hashtag";
    
    NSString *result1 = [inputVC removeHash:hashText];
    NSString *result2 = [inputVC removeHash:nonHashText];
    
    XCTAssertEqualObjects(result1, expectedResult, @"Hashtag not removed correctly");
    XCTAssertEqualObjects(result2, expectedResult, @"Non-hash text incorrectly modified");
    
}

- (void)testTwitter {
    
}

- (void)testDialogHasBeenPresented {
    
}

- (void)testUserDeniedPermission {
    
}

- (void)testUserHasNoAccount {
    
}

- (void)testSaveHashtag {
    
}

- (void)testRetrieveHashtag {
    
}


//- (void)testExample {
//    // This is an example of a functional test case.
//    XCTAssert(YES, @"Pass");
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
