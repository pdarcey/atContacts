//
//  PDXNavigationControllerTests.m
//  @Contacts
//
//  Created by Paul Darcey on 16/10/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

@import UIKit;
@import QuartzCore;
#import "FBSnapshotTestCase.h"
#import "PDXNavigationController.h"
#import "PDXNavigationController+TestExtensions.h"

@interface PDXNavigationControllerTests : FBSnapshotTestCase

@end

@implementation PDXNavigationControllerTests

- (void)setUp {
    [super setUp];
    // Flip this to YES to record images in the reference image directory.
    // You need to do this the first time you create a test and whenever you change the snapshotted views.
    // Tests running in record mode will allways fail so that you know that you have to do something here before you commit.
    self.recordMode = NO;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testShortMessage {
    NSString *message = @"Hello";
    PDXNavigationController *navigationController = [PDXNavigationController new];
    UILabel *messageView = [navigationController makeErrorMessage:message];
    FBSnapshotVerifyView(messageView, nil);
}

- (void)testLongMessage {
    NSString *message = @"Error\n\nThere has been a problem accessing your Twitter account. There has been a problem accessing your Twitter account. There has been a problem accessing your Twitter account. There has been a problem accessing your Twitter account. There has been a problem accessing your Twitter account. There has been a problem accessing your Twitter account.";
    PDXNavigationController *navigationController = [PDXNavigationController new];
    UILabel *messageView = [navigationController makeErrorMessage:message];
    FBSnapshotVerifyView(messageView, nil);
}

- (void)testNilMessage {
    PDXNavigationController *navigationController = [PDXNavigationController new];
    UILabel *messageView = [navigationController makeErrorMessage:nil];
    FBSnapshotVerifyView(messageView, nil);
}

- (void)testTypicalMessage {
    NSString *message = @"There has been a problem accessing your Twitter account";
    PDXNavigationController *navigationController = [PDXNavigationController new];
    UILabel *messageView = [navigationController makeErrorMessage:message];
    FBSnapshotVerifyView(messageView, nil);
}

@end
