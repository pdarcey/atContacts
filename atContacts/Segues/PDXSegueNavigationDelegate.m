//
//  PDXSegueNavigationDelegate.m
//  @Contacts
//
//  Created by Paul Darcey on 10/10/2014.
//  Copyright © 2014 Paul Darcey. All rights reserved.
//

#import "PDXSegueNavigationDelegate.h"
#import "PDXPushTransition.h"
#import "PDXPopTransition.h"

@implementation PDXSegueNavigationDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    
    if (operation == UINavigationControllerOperationPush) {
        PDXPushTransition *transition = [PDXPushTransition new];

        return transition;
    } else if (operation == UINavigationControllerOperationPop) {
        PDXPopTransition *transition = [PDXPopTransition new];
        
        return transition;
    }

    
    return nil;
}

@end
