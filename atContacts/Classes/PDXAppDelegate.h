//
//  AppDelegate.h
//  atContacts
//
//  Created by Paul Darcey on 27/08/2014.
//  © 2014 Paul Darcey. All rights reserved.
//

@import UIKit;
#import "PDXTwitterCommunicator.h"

@interface PDXAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *dataArray;

- (NSArray *)dataArray;

@end

