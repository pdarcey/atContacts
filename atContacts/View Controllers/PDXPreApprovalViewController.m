//
//  PreApprovalViewController.m
//  atContacts
//
//  Created by Paul Darcey on 29/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXPreApprovalViewController.h"
#import "PDXInputViewController.h"

@interface PDXPreApprovalViewController ()

@end

@implementation PDXPreApprovalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PDXTwitterCommunicator *twitter = [self twitter];
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
    [defaults setBool:YES forKey:@"dialogHasBeenPresented"];
    [defaults setBool:NO forKey:@"userDeniedPermission"];
    [defaults setBool:NO forKey:@"userHasNoAccount"];
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
    [defaults setBool:YES forKey:@"dialogHasBeenPresented"];
    [defaults setBool:YES forKey:@"userDeniedPermission"];
    [defaults setBool:NO forKey:@"userHasNoAccount"];
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
    [defaults setBool:YES forKey:@"dialogHasBeenPresented"];
    [defaults setBool:NO forKey:@"userDeniedPermission"];
    [defaults setBool:YES forKey:@"userHasNoAccount"];
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
    
}

#pragma mark - Convenience methods

/**
 *  Convenience method to retrieve Twitter Communicator
 *
 *  @return Twitter Communicator
 *
 *  @since 1.0
 */
- (PDXTwitterCommunicator *)twitter {
    if (_twitter != nil) {
        return _twitter;
    }
    PDXTwitterCommunicator *twitterCommunicator = [PDXTwitterCommunicator new];
    _twitter = twitterCommunicator;
    return _twitter;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end