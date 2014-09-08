//
//  ViewController.h
//  atContacts
//
//  Created by Paul Darcey on 27/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDXViewController.h"

@interface PDXInputViewController : PDXViewController

@property (weak, nonatomic) IBOutlet UITextField *twitterName;
@property (weak, nonatomic) IBOutlet UITextField *hashtag;

- (IBAction)findTwitterName;
- (IBAction)touchDownOutsideFields;
- (IBAction)startHashtagEditing:(id)sender;
- (IBAction)endHashtagEditing;

@end

