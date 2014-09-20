//
//  PreApprovalViewController.h
//  atContacts
//
//  Created by Paul Darcey on 29/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

@import UIKit;
#import "PDXAppDelegate.h"
#import "PDXTwitterCommunicator.h"
#import "PDXInputViewController.h"

// View that is displayed before triggering Apple's system approval dialog for access to the user's Twitter account
// Allows us to control whether or not to trigger Apple's dialog

@interface PDXPreApprovalViewController : UIViewController <PDXTwitterCommunicatorDelegate>

@property (weak, nonatomic) IBOutlet UIButton *permissionGranted;
@property (weak, nonatomic) IBOutlet UIButton *permissionDenied;
@property (weak, nonatomic) IBOutlet UIButton *noTwitterAccount;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) PDXTwitterCommunicator *twitter;
@property (weak, nonatomic) PDXInputViewController *parent;

- (IBAction)permissionGranted:(id)sender;
- (IBAction)permissionDenied:(id)sender;
- (IBAction)noTwitterAccount:(id)sender;

@end
