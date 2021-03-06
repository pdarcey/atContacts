//
//  ResultsViewController.h
//  atContacts
//
//  Created by Paul Darcey on 1/09/2014.
//  © 2014 Paul Darcey. All rights reserved.
//

@import UIKit;
#import "PDXAppDelegate.h"
#import "PDXInputViewController.h"
#import "PDXTwitterCommunicator.h"
#import "PDXContactMaker.h"
#import "PDXConstants.h"

// Constants
static NSString * const kFakeTextField = @"fakeTextField";

@interface PDXResultsViewController : UIViewController <UITextFieldDelegate, PDXTwitterCommunicatorDelegate, PDXContactMakerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (weak, nonatomic) IBOutlet UILabel *lastName;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *twitterHandle;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *webAddress;
@property (weak, nonatomic) IBOutlet UITextView *twitterDescription;
@property (weak, nonatomic) IBOutlet UIImageView *indicator;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *contactsButton;
@property (weak, nonatomic) IBOutlet UIButton *bothButton;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurOverlay;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;

@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) PDXInputViewController *parent;
@property (strong, nonatomic) NSString *hashtag;
@property (strong, nonatomic) NSString *idString;
@property BOOL following;

@property (weak, nonatomic) NSArray *originalConstraints;
@property (weak, nonatomic) UITextField *realTextField;

- (IBAction)followOnTwitter:(UIButton *)sender;
- (IBAction)addToContacts;
- (IBAction)followAndAdd:(UIButton *)sender;
- (IBAction)swipeToDismiss;

- (void)initialiseData:(NSDictionary *)data;

@end
