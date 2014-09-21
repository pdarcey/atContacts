//
//  PreApprovalViewController.m
//  atContacts
//
//  Created by Paul Darcey on 29/08/2014.
//  © 2014 Paul Darcey. All rights reserved.
//

#import "PDXPreApprovalViewController.h"
#import "PDXInputViewController.h"

@interface PDXPreApprovalViewController ()

@end

@implementation PDXPreApprovalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    twitter.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

/**
 *  User has chosen to allow us to use their Twitter identity. We can proceed as normal
 *
 *  @param sender Will always be permissionGranted button
 *
 *  @since 1.0
 */
- (IBAction)permissionGranted:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kUserDefaultTwitterPreApprovalDialogHasBeenPresented];
    [defaults setBool:NO forKey:kUserDefaultUserDeniedPermissionToTwitter];
    [defaults setBool:NO forKey:kUserDefaultUserHasNoTwitterAccount];
    [self dismissViewController];
}

/**
 *  User has chosen to deny us the use of their Twitter identity. We cannot proceed and will not trigger
 *     Apple's dialog box
 *
 *  @param sender Will always be permissionDenied button
 *
 *  @since 1.0
 */
- (IBAction)permissionDenied:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kUserDefaultTwitterPreApprovalDialogHasBeenPresented];
    [defaults setBool:YES forKey:kUserDefaultUserDeniedPermissionToTwitter];
    [defaults setBool:NO forKey:kUserDefaultUserHasNoTwitterAccount];
    [self dismissViewController];
}

/**
 *  User has said they do not have a Twitter identity. We cannot proceed and will not trigger
 *     Apple's dialog box
 *
 *  @param sender Will always be noTwitterAccount button
 *
 *  @since 1.0
 */
- (IBAction)noTwitterAccount:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kUserDefaultTwitterPreApprovalDialogHasBeenPresented];
    [defaults setBool:NO forKey:kUserDefaultUserDeniedPermissionToTwitter];
    [defaults setBool:YES forKey:kUserDefaultUserHasNoTwitterAccount];
    [self dismissViewController];
}

/**
 *  Dismisses this view and returns to the Input view
 *
 *  @since 1.0
 */
- (void)dismissViewController {
    PDXInputViewController *superview = (PDXInputViewController *)_parent;
    NSString *name = superview.twitterName.text;
    PDXTwitterCommunicator *twitter = [self twitter];
    twitter.delegate = _parent;
    [[self twitter] getUserInfo:name];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)displayErrorMessage:(NSString *)message {
    // Accessibility announcement
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
    
    // Animation
    dispatch_async(dispatch_get_main_queue(), ^{
        _errorMessage.text = message;
        _errorMessage.alpha = 0;
        _errorMessage.hidden = NO;
        CGFloat duration = 0.8f;
        
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{_errorMessage.alpha = 1;}
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:duration
                                                   delay:2.0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{_errorMessage.alpha = 0;}
                                              completion:^(BOOL finished) {
                                                  _errorMessage.hidden = YES;
                                              }
                              ];
                         }];
    });
}

@end
