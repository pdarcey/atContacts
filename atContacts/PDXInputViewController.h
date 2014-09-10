//
//  ViewController.h
//  atContacts
//
//  Created by Paul Darcey on 27/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDXViewController.h"

@interface PDXInputViewController : PDXViewController <PDXTwitterCommunicatorDelegate>

@property (weak, nonatomic) IBOutlet UITextField *twitterName;
@property (weak, nonatomic) IBOutlet UITextField *hashtag;
@property (weak, nonatomic) PDXTwitterCommunicator *twitter;

- (IBAction)findTwitterName;
- (IBAction)endHashtagEditing;

- (void)reset;

@end

