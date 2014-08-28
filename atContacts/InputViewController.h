//
//  ViewController.h
//  atContacts
//
//  Created by Paul Darcey on 27/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *twitterName;
@property (weak, nonatomic) IBOutlet UITextField *hashtag;

- (IBAction)findTwitterName:(id)sender;
- (IBAction)touchDownOutsideFields:(id)sender;
- (IBAction)startHashtagEditing:(id)sender;
- (IBAction)endHashtagEditing:(id)sender;

@end

