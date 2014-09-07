//
//  PreApprovalViewController.h
//  atContacts
//
//  Created by Paul Darcey on 29/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDXNameFinder.h"

@interface PDXPreApprovalViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *permissionGranted;
@property (weak, nonatomic) IBOutlet UIButton *permissionDenied;
@property (weak, nonatomic) IBOutlet UIButton *noTwitterAccount;
@property (weak, nonatomic) PDXNameFinder *nameFinder;

- (IBAction)permissionGranted:(id)sender;
- (IBAction)permissionDenied:(id)sender;
- (IBAction)noTwitterAccount:(id)sender;

@end
