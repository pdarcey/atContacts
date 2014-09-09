//
//  AppDelegate.h
//  atContacts
//
//  Created by Paul Darcey on 27/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDXDataModel.h"
#import "PDXTwitterCommunicator.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *dataArray;

- (NSArray *)dataArray;

@end

