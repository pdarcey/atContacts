//
//  PDXPushSegue.m
//  @Contacts
//
//  Created by Paul Darcey on 6/10/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXPushSegue.h"

@implementation PDXPushSegue

- (void)perform {
    UIViewController *sourceViewController = (UIViewController *)[self sourceViewController];
    UIViewController *destinationController = (UIViewController *)[self destinationViewController];
    
    CATransition *transition = [CATransition animation];
    transition.duration = .25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [sourceViewController.view.layer addAnimation:transition forKey:kCATransition];
    
    [sourceViewController.navigationController pushViewController:destinationController animated:NO];
}

@end
