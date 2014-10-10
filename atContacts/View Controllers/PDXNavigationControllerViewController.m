//
//  PDXNavigationControllerViewController.m
//  @Contacts
//
//  Created by Paul Darcey on 10/10/2014.
//  Copyright © 2014 Paul Darcey. All rights reserved.
//

#import "PDXNavigationControllerViewController.h"
#import "PDXSegueNavigationDelegate.h"
#import "PDXInputViewController.h"
#import "PDXResultsViewController.h"
#import "PDXPushTransition.h"

@interface PDXNavigationControllerViewController () {

    id <UINavigationControllerDelegate> _navDelegate;
    
}

@end

@implementation PDXNavigationControllerViewController

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
    // Display view
    PDXResultsViewController *results = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Results"];
    results.data = data;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self pushViewController:results animated:YES];
    });
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
    // Accessibility announcement
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
    
    // Set up error message label
    CGRect defaultRect = CGRectMake(0, 0, 200, 200);
    UILabel *errorMessage = [[UILabel alloc] initWithFrame:defaultRect];
    errorMessage.backgroundColor = [[UIColor kAppBlackColor] colorWithAlphaComponent:0.7];
    errorMessage.textColor = [UIColor kAppWhiteColor];
    errorMessage.textAlignment = NSTextAlignmentCenter;
    errorMessage.numberOfLines = 0;
    errorMessage.layer.cornerRadius = 6;
    errorMessage.clipsToBounds = YES;
    [errorMessage textRectForBounds:CGRectInset(errorMessage.bounds, 20, 20) limitedToNumberOfLines:errorMessage.numberOfLines];
    errorMessage.layer.shadowColor = [[UIColor blackColor] CGColor];
    errorMessage.layer.shadowOffset = CGSizeMake(0, 5);
    errorMessage.layer.shadowOpacity = 0.25;
    // Reset default size
    errorMessage.text = message;
    [errorMessage sizeToFit]; // Needed to get the appropriate height because the font size can be changed by user and by the message
    CGRect requiredBounds = CGRectUnion(errorMessage.bounds, defaultRect);
    
    // Position it on the screen
    CGFloat x = (self.topViewController.view.frame.size.width - requiredBounds.size.width) / 2;
    CGFloat y = ((self.topViewController.view.frame.size.height * 3 / 4) - requiredBounds.size.height) / 2;
    
    if (y < 0) {
        y = 0;
    }
    errorMessage.frame = CGRectMake(x, y, requiredBounds.size.width, requiredBounds.size.height);

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
