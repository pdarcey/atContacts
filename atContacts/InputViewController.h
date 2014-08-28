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
@property (weak, nonatomic) IBOutlet UILabel *hashtags;

- (IBAction)findTwitterName:(id)sender;

@end

