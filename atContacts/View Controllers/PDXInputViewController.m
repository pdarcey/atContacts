//
//  ViewController.m
//  atContacts
//
//  Created by Paul Darcey on 27/08/2014.
//  © 2014 Paul Darcey. All rights reserved.
//

#import "PDXInputViewController.h"
#import "PDXTwitterCommunicator.h"
#import "PDXResultsViewController.h"

@interface PDXInputViewController ()

@end

@implementation PDXInputViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

/**
 *  When view appears, reset input fields
 *
 *  @since 1.0
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];

    [self reset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

/**
 *  Sets twitterName to @"", the hashtag to the last-used hashtag, hides the errorMessage field, and prepares to receive input in twitterName
 *
 *  @since 1.0
 */
- (void)reset {
    [_twitterName setText:kBlankString];
    [_twitterName becomeFirstResponder];
    _hashtag.text = [self retrieveHashtag];
    _errorMessage.hidden = YES;
}

/**
 *  Takes name from twitterName field and tries to find information from Twitter for that user
 *
 *  @param sender What field triggered this. Will almost(?) always be by hitting Return in twitterName textField
 *
 *  @since 1.0
 */
- (IBAction)findTwitterName {    
//    self.activitySpinner.hidden = NO;
//    [activitySpinner startAnimating];
    
    // Ensure that user hasn't included the initial "@" in the user name
    if (_twitterName.text.length > 0) {
        NSString *name = _twitterName.text;
        NSString *firstCharacter = [name substringToIndex:1];

        if (![firstCharacter isEqualToString:kAtSign]) {
            name = [name stringByReplacingOccurrencesOfString:kAtSign withString:kBlankString];
        }

        PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
        twitter.delegate = self;
        [twitter getUserInfo:name];
        
    } else {
        [_twitterName becomeFirstResponder];
    }
}

#pragma mark - Hashtag editing

/**
 *  Does a little "pop" and changes the textField from looking like a label to looking like an input field
 *
 *  @param textField Which textField has begun editing?
 *
 *  @since 1.0
 */
- (IBAction)popTextField:(UITextField *)textField {
    if (textField == _hashtag) {
        [self popAnimation:textField];
        [_hashtag becomeFirstResponder];
    }
}

/**
 *  Protocol method called to see if a UIControl should return
 *
 *  We use it to determine which action to take, then always return YES
 *
 *  @param textField The text field in which the Return key has been pressed
 *
 *  @return Always returns YES
 *
 *  @since 1.0
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _twitterName) {
        [self findTwitterName];
    } else if (textField == _hashtag) {
        [self endHashtagEditing];
    }
    
    return YES;
}

/**
 *  Resets hashtag to look like a label, rather than an input field, and adds the leading "#" if necessary
 *  Called by tap outside the UITextFields, or when editing in the hashtag field ends
 *
 *  @param sender Not used; irrelevent
 *
 *  @since 1.0
 */
- (IBAction)endHashtagEditing {
    if (_hashtag.text.length > 0) {
        NSString *firstCharacter = [_hashtag.text substringToIndex:1];

        if (![firstCharacter isEqualToString:kHashSign]) {
            _hashtag.text = [kHashSign stringByAppendingString:_hashtag.text];
        }
        [self saveHashtag:_hashtag.text];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.1f animations:^{
            _hashtag.borderStyle = UITextBorderStyleNone;
            _hashtag.backgroundColor = [UIColor clearColor];
        }];
    });
    [_twitterName becomeFirstResponder];
}

/**
 *  Does a little "pop" and changes the textField from looking like a label to looking like an input field
 *
 *  @param textField The UITextField to "pop". Should only ever be called for the hashtag textField
 *
 *  @since 1.0
 */
- (void)popAnimation:(UITextField *)textField {
    dispatch_async(dispatch_get_main_queue(), ^{
        textField.borderStyle = _twitterName.borderStyle;
        textField.backgroundColor = _twitterName.backgroundColor;
        
        CGFloat percent = 0.2; // Try 20%
        [UIView animateWithDuration:0.1 animations:^{
            CGAffineTransform embiggen = CGAffineTransformMakeScale(1 + percent, 1 + percent);
            textField.transform = embiggen;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    CGAffineTransform shrink   = CGAffineTransformMakeScale(1, 1);
                    textField.transform = shrink;
                }];
            }
        }];
    });
}

#pragma mark - Convenience methods for User Defaults

/**
 *  Convenience method to retrieve dialogHasBeenPresented from User Defaults
 *  Used to decide whether user has already been presented with pre-approval dialog
 *
 *  @return YES if the dialog has already been presented; NO if not
 *
 *  @since 1.0
 */
- (BOOL)dialogHasBeenPresented {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL dialogHasBeenPresented = [defaults boolForKey:kUserDefaultTwitterPreApprovalDialogHasBeenPresented];
    
    return dialogHasBeenPresented;
}

/**
 *  Convenience method to retrieve userDeniedPermission from User Defaults
 *  User has already been presented with pre-approval dialog
 *
 *  @return YES if the user has denied permission to use their stored Twitter credentials; NO if not
 *
 *  @since 1.0
 */
- (BOOL)userDeniedPermission {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL userDeniedPermission = [defaults boolForKey:kUserDefaultUserDeniedPermissionToTwitter];
    
    return userDeniedPermission;
}

/**
 *  Convenience method to retrieve userHasNoAccount from User Defaults
 *  User has already been presented with pre-approval dialog
 *
 *  @return YES if the user has told us that they do not have a Twitter account; NO if not
 *
 *  @since 1.0
 */
- (BOOL)userHasNoAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL userHasNoAccount = [defaults boolForKey:kUserDefaultUserHasNoTwitterAccount];
    
    return userHasNoAccount;
}

/**
 *  Stores the entered hashtag in user defaults, so it can be used later (Hashtag should always have leading #)
 *
 *  @param hashtag Text from the hashtag field
 *
 *  @since 1.0
 */
- (void)saveHashtag:(NSString *)hashtag {
    if (![hashtag isEqualToString:kBlankString]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:hashtag forKey:kUserDefaultLastUsedHashtag];
        [defaults synchronize];
    }
}

/**
 *  Retrieves the last used hashtag from user defaults
 *
 *  @return The last used hashtag (with the leading #), or @""
 *
 *  @since 1.0
 */
- (NSString *)retrieveHashtag {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *hashtag = [defaults valueForKey:kUserDefaultLastUsedHashtag];

    if (hashtag) {
        
        return hashtag;
    }
    hashtag = kBlankString;
    
    return hashtag;
}

#pragma mark - Protocol methods for PDXTwitterCommunicatorDelegate

/**
 *  Protocol method optional for PDXTwitterCommunicatorDelegate
 *
 *  Creates a new instance of the Results scene from the Main storyboard, and passes it a dictionary of results data to display
 *
 *  @param data A dictionary of results data
 *
 *  @since 1.0
 */
- (void)displayInfo:(NSDictionary *)data {    
    // Initialise Results screen
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:kStoryboardMain bundle:nil];
    PDXResultsViewController *resultsViewController = [mainStoryboard instantiateViewControllerWithIdentifier:kStoryboardIdentifierResults];

    resultsViewController.data = data;
    resultsViewController.parent = self;
    resultsViewController.hashtag = _hashtag.text;
    resultsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    // Accessibility announcement
    NSString *message = NSLocalizedString(@"Presenting results", "Presenting results");
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
    
    // Display view
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:resultsViewController animated:YES completion:nil];
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

- (void)displayAlert:(UIAlertController *)alert {
    // Accessibility announcement
    NSString *message = alert.message;
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
    
    // Animation
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
    
}

# pragma mark - Notification Center Notifications

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    _atSymbol.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _twitterName.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _hashtag.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _errorMessage.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [self.view setNeedsLayout];
}

@end
