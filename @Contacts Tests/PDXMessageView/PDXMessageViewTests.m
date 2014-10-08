//
//  PDXMessageViewTests.m
//  @Contacts
//
//  Created by Paul Darcey on 8/10/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "FBSnapshotTestCase.h"
#import "PDXMessageView.h"

@interface PDXMessageViewTests : FBSnapshotTestCase

@end

@implementation PDXMessageViewTests

- (void)setUp {
    [super setUp];
    // Flip this to YES to record images in the reference image directory.
    // You need to do this the first time you create a test and whenever you change the snapshotted views.
    // Tests running in record mode will allways fail so that you know that you have to do something here before you commit.
    self.recordMode = NO;
}

- (void)testShortMessage {
    NSString *message = @"Hello";
    PDXMessageView *view = [[PDXMessageView alloc] initWithMessage:message];
    FBSnapshotVerifyView(view, nil);
}

- (void)testLongMessage {
    NSString *message = @"Error\n\nThere has been a problem accessing your Twitter account. There has been a problem accessing your Twitter account. There has been a problem accessing your Twitter account. There has been a problem accessing your Twitter account. There has been a problem accessing your Twitter account. There has been a problem accessing your Twitter account.";
    PDXMessageView *view = [[PDXMessageView alloc] initWithMessage:message];
    FBSnapshotVerifyView(view, nil);
}

- (void)testNilMessage {
    PDXMessageView *view = [[PDXMessageView alloc] initWithMessage:nil];
    FBSnapshotVerifyView(view, nil);
}

- (void)testTypicalMessage {
    NSString *message = @"There has been a problem accessing your Twitter account";
    PDXMessageView *view = [[PDXMessageView alloc] initWithMessage:message];
    FBSnapshotVerifyView(view, nil);
}

@end
