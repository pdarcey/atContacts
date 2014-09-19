//
//  ViewController.h
//  atContacts
//
//  Created by Paul Darcey on 27/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

@import UIKit;
#import "PDXTwitterCommunicator.h"

# pragma mark - Constants

static NSString * const kAtSign = @"@";
static NSString * const kHashSign = @"#";

// Storyboard Names:
static NSString * const kStoryboardMain = @"Main";
static NSString * const kStoryboardPreApproval = @"PreApproval";
static NSString * const kStoryboardIdentifierResults = @"Results";
static NSString * const kStoryboardIdentifierPreApproval = @"PreApproval";
static NSString * const kStoryboardIdentifierInput = @"InputView";

# pragma mark - Interface

@interface PDXInputViewController : UIViewController <PDXTwitterCommunicatorDelegate>

@property (weak, nonatomic) IBOutlet UITextField *twitterName;
@property (weak, nonatomic) IBOutlet UITextField *hashtag;
@property (weak, nonatomic) PDXTwitterCommunicator *twitter;
@property BOOL searching;
@property (strong, nonatomic) IBOutlet UILabel *errorMessage;

- (IBAction)findTwitterName;
- (IBAction)endHashtagEditing;
- (IBAction)popTextField:(UITextField *)textField;

- (void)reset;

@end

