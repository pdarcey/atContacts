//
//  PDXNavigationControllerViewController.m
//  @Contacts
//
//  Created by Paul Darcey on 10/10/2014.
//  Copyright © 2014 Paul Darcey. All rights reserved.
//

#import "PDXNavigationController.h"
#import "PDXSegueNavigationDelegate.h"
#import "PDXInputViewController.h"
#import "PDXResultsViewController.h"
#import "PDXPushTransition.h"

@interface PDXNavigationController () {

    id <UINavigationControllerDelegate> _navDelegate;
    
}

@end

@implementation PDXNavigationController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _segueDelegate = [PDXSegueNavigationDelegate new];
        self.delegate = _segueDelegate;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Twitter Protocol

- (void)displayInfo:(NSDictionary *)data {
    // Prepare Results view
    PDXResultsViewController *results = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Results"];
    results.data = data;
    
    // Set up animation

    dispatch_async(dispatch_get_main_queue(), ^{
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setDuration:2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[self.navigationController.view layer] addAnimation:animation forKey:@"AnimationFromRight"];
        [self pushViewController:results animated:YES];
    });
}

- (void)test:(NSDictionary *)data {
    // Display view
    PDXResultsViewController *results = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Results"];
    results.data = data;

    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setDuration:0.65f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.navigationController.view layer] addAnimation:animation forKey:@"AnimationFromRight"];

}

/**
 *  Required protocol method for PDXTwitterCommunicatorDelegate
 *
 *  Animates a message passed to it to fade in/fade out
 *
 *  @param message Text to display
 *
 *  @since 1.0
 */
- (void)displayErrorMessage:(NSString *)message {
    if (message) {
        // Accessibility announcement
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
        
        UIView *errorMessage = [self makeErrorMessage:message];
        // Set alpha to 0 to start the fade-in transition
        errorMessage.alpha = 0;
        [self.topViewController.view addSubview:errorMessage];
        
        // Animation
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat duration = 0.8f;
            
            [UIView animateWithDuration:duration
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{errorMessage.alpha = 1;}
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration:duration
                                                       delay:2.0
                                                     options:UIViewAnimationOptionCurveEaseOut
                                                  animations:^{errorMessage.alpha = 0;}
                                                  completion:^(BOOL finished) {
                                                      [errorMessage removeFromSuperview];
                                                  }
                                  ];
                             }];
        });
    }
}

- (UIView *)makeErrorMessage:(NSString *)message {
    // Add Rounded Rect
    CGRect defaultBackgroundSize = CGRectMake(0, 0, 200, 200);
    UIView *blackBackground = [[UIView alloc] initWithFrame:defaultBackgroundSize];
    blackBackground.backgroundColor = [[UIColor kAppBlackColor] colorWithAlphaComponent:0.7];
    blackBackground.layer.cornerRadius = 6;
    blackBackground.layer.masksToBounds = NO;
    blackBackground.translatesAutoresizingMaskIntoConstraints = NO;

    // Add shadow
    blackBackground.layer.shadowColor = [[UIColor blackColor] CGColor];
    blackBackground.layer.shadowOffset = CGSizeMake(0, 5);
    blackBackground.layer.shadowOpacity = 0.25;
    
    // Add label, format it, and set its contents
    CGFloat margin = 12;
    CGRect defaultMessageSize = CGRectInset(defaultBackgroundSize, margin, margin);
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:defaultMessageSize];
    messageLabel.layer.masksToBounds = YES;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textColor = [UIColor kAppWhiteColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = message;
    messageLabel.adjustsFontSizeToFitWidth = NO;
    messageLabel.numberOfLines = 0;
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [messageLabel sizeToFit];
    
    CGRect requiredBackgroundSize = CGRectOffset(messageLabel.bounds, margin * 2, margin * 2);
    blackBackground.frame = CGRectUnion(defaultBackgroundSize, requiredBackgroundSize);
    
    // Position message on the background
    [blackBackground addSubview:messageLabel];
    CGFloat messageX = (blackBackground.bounds.size.width - messageLabel.bounds.size.width) / 2;
    CGFloat messageY = (blackBackground.bounds.size.height - messageLabel.bounds.size.height) / 2;
    messageLabel.frame = CGRectMake(messageX, messageY, messageLabel.bounds.size.width, messageLabel.bounds.size.height);
    
    // Position it on the screen
    CGFloat x = (self.topViewController.view.frame.size.width - blackBackground.bounds.size.width) / 2;
    CGFloat y = ((self.topViewController.view.frame.size.height * 3 / 4) - blackBackground.bounds.size.height) / 2;
    
    if (y < 0) {
        y = 0;
    }
    blackBackground.frame = CGRectMake(x, y, blackBackground.bounds.size.width, blackBackground.bounds.size.height);

    return blackBackground;
}

/**
 *  Required protocol method for PDXTwitterCommunicatorDelegate and PDXContactMakerDelegate
 *
 *  Displays a UIAlertController alert which is already configured
 *
 *  @param alert Pre-configured alert
 *
 *  @since 1.0
 */
- (void)displayAlert:(UIAlertController *)alert {
    // Accessibility announcement
    NSString *message = alert.message;
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
    
    // Animation
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.topViewController presentViewController:alert animated:YES completion:nil];
    });
    
}

- (void)newContactMade:(BOOL)success {
    
}

@end
