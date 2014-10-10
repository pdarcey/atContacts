//
//  PDXPopTransition.m
//  @Contacts
//
//  Created by Paul Darcey on 10/10/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXPopTransition.h"
#import "PDXInputViewController.h"
#import "PDXResultsViewController.h"

@implementation PDXPopTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 2.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Get the two view controllers
    PDXInputViewController *destination = (PDXInputViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    PDXResultsViewController *source = (PDXResultsViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // Set data to be displayed
    [destination reset];
    
    // Get the container view - where the animation has to happen
    UIView *containerView = [transitionContext containerView];
    
    // Add the two VC views to the container. Hide the destination
    [containerView addSubview:destination.view];
    [containerView addSubview:source.view];
    
    // Perform the animation
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:0
                     animations:^{
                         [source.view removeFromSuperview];
                     }
                     completion:^(BOOL finished) {
                         // And then we need to tell the context that we're done
                         [transitionContext completeTransition:YES];
                     }];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    
}

@end
