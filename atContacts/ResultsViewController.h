//
//  ResultsViewController.h
//  atContacts
//
//  Created by Paul Darcey on 1/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ResultsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (weak, nonatomic) IBOutlet UILabel *lastName;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *twitterHandle;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *webAddress;
@property (weak, nonatomic) IBOutlet UITextView *twitterDescription;
@property (weak, nonatomic) IBOutlet UIImageView *indicator;

- (IBAction)followOnTwitter:(UIButton *)sender;
- (IBAction)addToContacts:(UIButton *)sender;
- (IBAction)followAndAdd:(UIButton *)sender;

- (IBAction)swipeToDismiss;

@end
