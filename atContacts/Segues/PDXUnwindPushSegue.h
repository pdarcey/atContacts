//
//  PDXUnwindPushSegue.h
//  @Contacts
//
//  Created by Paul Darcey on 6/10/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PDXInputViewController;
@class PDXResultsViewController;

@interface PDXUnwindPushSegue : UIStoryboardSegue

@property (weak, readonly, nonatomic) PDXResultsViewController *sourceViewController;
@property (weak, readonly, nonatomic) PDXInputViewController *destinationViewController;

@end
