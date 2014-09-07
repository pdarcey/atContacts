//
//  ResultsViewController.h
//  atContacts
//
//  Created by Paul Darcey on 1/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface PDXResultsViewController : UIViewController <UITextFieldDelegate>

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
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurOverlay;
@property (weak, nonatomic) NSArray *originalConstraints;
@property (weak, nonatomic) UITextField *realTextField;


- (IBAction)followOnTwitter:(UIButton *)sender;
- (IBAction)addToContacts:(UIButton *)sender;
- (IBAction)followAndAdd:(UIButton *)sender;

- (IBAction)swipeToDismiss;

@end
