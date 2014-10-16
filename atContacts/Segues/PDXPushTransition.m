//
//  PDXPushTransition.m
//  @Contacts
//
//  Created by Paul Darcey on 10/10/2014.
//  Copyright © 2014 Paul Darcey. All rights reserved.
//

#import "PDXPushTransition.h"
#import "PDXInputViewController.h"
#import "PDXResultsViewController.h"
#import "PDXNavigationController.h"

@implementation PDXPushTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 2.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    // Get the two view controllers
    PDXInputViewController *source = (PDXInputViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    PDXResultsViewController *destination = (PDXResultsViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Set data to be displayed
    destination.data = source.data;
    
    // Get the container view - where the animation has to happen
    UIView *containerView = [transitionContext containerView];
    
    // Add the two VC views to the container. Hide the destination
    [containerView addSubview:source.view];
    
    // Perform the animation
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:0
                     animations:^{                         
                         [containerView addSubview:destination.view];
                     }
                     completion:^(BOOL finished) {
                         // Let's get rid of the old VC view
                         [source.view removeFromSuperview];
                         // And then we need to tell the context that we're done
                         [transitionContext completeTransition:YES];
                     }];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    
}

@end
