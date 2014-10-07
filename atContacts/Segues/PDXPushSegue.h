//
//  PDXPushSegue.h
//  @Contacts
//
//  Created by Paul Darcey on 6/10/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PDXInputViewController;
@class PDXResultsViewController;

@interface PDXPushSegue : UIStoryboardSegue

@property (weak, readonly, nonatomic) PDXInputViewController *sourceViewController;
@property (weak, readonly, nonatomic) PDXResultsViewController *destinationViewController;

@end
