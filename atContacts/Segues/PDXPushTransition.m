//
//  PDXPushTransition.m
//  @Contacts
//
//  Created by Paul Darcey on 10/10/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXPushTransition.h"
#import "PDXInputViewController.h"
#import "PDXResultsViewController.h"

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
    
    // --- original (fade) ---
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:0
                     animations:^{
                         destination.view.alpha = 1.f;
                     }
                     completion:^(BOOL finished) {
                         // Let's get rid of the old VC view
                         [source.view removeFromSuperview];
                         // And then we need to tell the context that we're done
                         [transitionContext completeTransition:YES];
                     }];
    // --- end original ---

    // --- push ---
//    CATransition *transition = [CATransition animation];
//    transition.duration = [self transitionDuration:transitionContext];
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionMoveIn;
//    transition.subtype = kCATransitionFromRight;
//    
//    [containerView.layer addAnimation:transition forKey:kCATransition];
//    [containerView addSubview:destination.view];
//    [containerView.layer removeAnimationForKey:kCATransition];
//    
//    [source.view removeFromSuperview];
//    // And then we need to tell the context that we're done
//    [transitionContext completeTransition:YES];

    // --- end push ---
}

- (void)animationEnded:(BOOL)transitionCompleted {
    
}

@end
