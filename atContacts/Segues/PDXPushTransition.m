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
    
    // Set our ending frame. We'll modify this later if we have to
    CGRect endFrame = source.view.frame;
    
    if (self.presenting) {
        source.view.userInteractionEnabled = NO;
        
        [transitionContext.containerView addSubview:source.view];
        [transitionContext.containerView addSubview:destination.view];
        
        CGRect startFrame = endFrame;
        startFrame.origin.x += source.view.frame.size.width;
        
        destination.view.frame = startFrame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            source.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            destination.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [source removeFromParentViewController];
            [transitionContext completeTransition:YES];
        }];
    } else {
        destination.view.userInteractionEnabled = YES;
        
        [transitionContext.containerView addSubview:destination.view];
        [transitionContext.containerView addSubview:source.view];
        
        endFrame.origin.x += source.view.frame.size.width;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            destination.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            source.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [source removeFromParentViewController];
            [transitionContext completeTransition:YES];
        }];
    }
}

- (void)animationEnded:(BOOL)transitionCompleted {
    
}

@end
