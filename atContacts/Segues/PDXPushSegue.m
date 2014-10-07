//
//  PDXPushSegue.m
//  @Contacts
//
//  Created by Paul Darcey on 6/10/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXPushSegue.h"
#import "PDXInputViewController.h"
#import "PDXResultsViewController.h"

@implementation PDXPushSegue

- (void)perform {
    PDXInputViewController *source = [self sourceViewController];
    PDXResultsViewController *destination = [self destinationViewController];
    
    CATransition *transition = [CATransition animation];
    transition.duration = .75;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    [source.view.layer addAnimation:transition forKey:kCATransition];

    [source.view addSubview:destination.view];

    [destination.view removeFromSuperview]; // remove from temp super view
    [source presentViewController:destination animated:NO completion:NULL]; // present VC
}

@end
