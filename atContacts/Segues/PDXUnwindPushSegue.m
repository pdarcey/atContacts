//
//  PDXUnwindPushSegue.m
//  @Contacts
//
//  Created by Paul Darcey on 6/10/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXUnwindPushSegue.h"

@implementation PDXUnwindPushSegue

- (void)perform {
    UIViewController *sourceViewController = (UIViewController *)[self sourceViewController];
    UIViewController *destinationController = (UIViewController *)[self destinationViewController];
    
    CATransition *transition = [CATransition animation];
    transition.duration = .75;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromLeft;
    [sourceViewController.view.layer addAnimation:transition forKey:kCATransition];

    [sourceViewController.view.superview insertSubview:destinationController.view atIndex:0];

    NSLog(@"%@", @"About to unwind back to Input");
    [destinationController.view removeFromSuperview]; // remove from temp super view
    [sourceViewController dismissViewControllerAnimated:NO completion:NULL]; // dismiss VC
}

@end
