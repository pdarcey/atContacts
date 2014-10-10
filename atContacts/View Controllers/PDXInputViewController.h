//
//  ViewController.h
//  atContacts
//
//  Created by Paul Darcey on 27/08/2014.
//  © 2014 Paul Darcey. All rights reserved.
//

@import UIKit;
#import "PDXTwitterCommunicator.h"
#import "PDXSegueNavigationDelegate.h"

# pragma mark - Constants

// Standard string constants
static NSString * const kAtSign = @"@";
static NSString * const kHashSign = @"#";

// Storyboard Names:
static NSString * const kStoryboardMain = @"Main";
static NSString * const kStoryboardTwitterPreApproval = @"TwitterPreApproval";
static NSString * const kStoryboardIdentifierResults = @"Results";
static NSString * const kStoryboardIdentifierTwitterPreApproval = @"TwitterPreApproval";
static NSString * const kStoryboardIdentifierInput = @"InputView";

# pragma mark - Interface

@interface PDXInputViewController : UIViewController <PDXTwitterCommunicatorDelegate, UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet UITextField *twitterName;
@property (weak, nonatomic) IBOutlet UITextField *hashtag;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) IBOutlet UILabel *atSymbol;
@property (strong, nonatomic) NSDictionary *data;

- (IBAction)findTwitterName;
- (IBAction)endHashtagEditing;
- (IBAction)popTextField:(UITextField *)textField;

- (void)reset;

@end

