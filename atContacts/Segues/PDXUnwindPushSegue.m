//
//  PDXUnwindPushSegue.m
//  @Contacts
//
//  Created by Paul Darcey on 6/10/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXUnwindPushSegue.h"
#import "PDXInputViewController.h"
#import "PDXResultsViewController.h"

@implementation PDXUnwindPushSegue

- (void)perform {
    PDXResultsViewController *source = [self sourceViewController];
    PDXInputViewController *destination = [self destinationViewController];

    CATransition *transition = [CATransition animation];
    transition.duration = .75;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromLeft;
    [source.view.layer addAnimation:transition forKey:kCATransition];

    [source.view.superview insertSubview:destination.view atIndex:0];

    NSLog(@"%@", @"About to unwind back to Input");
    [destination.view removeFromSuperview]; // remove from temp super view
    [source dismissViewControllerAnimated:NO completion:NULL]; // dismiss VC
}

@end
