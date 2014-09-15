//
//  ViewController.h
//  atContacts
//
//  Created by Paul Darcey on 27/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

@import UIKit;
#import "PDXTwitterCommunicator.h"

@interface PDXInputViewController : UIViewController <PDXTwitterCommunicatorDelegate>

@property (weak, nonatomic) IBOutlet UITextField *twitterName;
@property (weak, nonatomic) IBOutlet UITextField *hashtag;
@property (weak, nonatomic) PDXTwitterCommunicator *twitter;

- (IBAction)findTwitterName;
- (IBAction)endHashtagEditing;
- (IBAction)popTextField:(UITextField *)textField;

- (void)reset;

@end

