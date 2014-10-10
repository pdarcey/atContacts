//
//  PDXNavigationControllerViewController.h
//  @Contacts
//
//  Created by Paul Darcey on 10/10/2014.
//  Copyright © 2014 Paul Darcey. All rights reserved.
//

@import UIKit;
#import "PDXTwitterCommunicator.h"
#import "PDXContactMaker.h"

@interface PDXNavigationControllerViewController : UINavigationController <PDXTwitterCommunicatorDelegate, PDXContactMakerDelegate>

@property (strong, nonatomic) id <UINavigationControllerDelegate> segueDelegate;

@end
