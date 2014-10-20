//
//  PDXPushTransition.h
//  @Contacts
//
//  Created by Paul Darcey on 10/10/2014.
//  Copyright © 2014 Paul Darcey. All rights reserved.
//
@import UIKit;

@interface PDXPushTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

@end
