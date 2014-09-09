//
//  ViewController.m
//  atContacts
//
//  Created by Paul Darcey on 27/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXInputViewController.h"
#import "PDXTwitterCommunicator.h"
#import "PDXResultsViewController.h"
#import "PDXPreApprovalViewController.h"

@interface PDXInputViewController ()

@end

@implementation PDXInputViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

/**
 *  When view appears, set up data model (if necessary) and set twitterName to become FirstResponder
 *
 *  @since 1.0
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

/**
 *  Sets twitterName to @"", the hashtag to the last used hashtag, and prepares to receive input in twitterName
 *
 *  @since 1.0
 */
- (void)reset {
    [_twitterName setText:@""];
    [_twitterName becomeFirstResponder];
    _hashtag.text = [self retrieveHashtag];
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
        if (![firstCharacter isEqualToString:@"@"]) {
            name = [name stringByReplacingOccurrencesOfString:@"@" withString:@""];
        }

        // Check if permission has previously been asked for
        if (![self dialogHasBeenPresented]) {
            [self presentPreApprovalDialog];
            
        } else {
            
            PDXTwitterCommunicator *twitter = [self twitter];
            twitter.delegate = self;
            [twitter getUserInfo:name];

        }
        
    } else {
        [_twitterName becomeFirstResponder];
    }
}

#pragma mark - Hashtag editing

/**
 *  Delegate method for UITextFields, called when user hits Return while in UITextField
 *
 *  If user is in twitterName, finds the twitterName;
 *
 *  if user in in hastag field, ends hashtag editing and activates twitterName
 *
 *  @param textField Identifies which UITextField initiated the call
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
 *  Does a little "pop" and changes the textField from looking like a label to looking like an input field
 *
 *  @param sender Not used; irrelevent
 *
 *  @since 1.0
 */
- (IBAction)startHashtagEditing:(id)sender {
    [self popAnimation:sender];
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
    _hashtag.borderStyle = UITextBorderStyleNone;
    _hashtag.backgroundColor = [UIColor clearColor];
    if (_hashtag.text.length > 0) {
        [self saveHashtag:_hashtag.text];
        NSString *firstCharacter = [_hashtag.text substringToIndex:1];
        if (![firstCharacter isEqualToString:@"#"]) {
            _hashtag.text = [@"#" stringByAppendingString:_hashtag.text];
        }
    }
    [_twitterName becomeFirstResponder];
    
}

/**
 *  Does a little "pop" and changes the textField from looking like a label to looking like an input field
 *
 *  @param textField The UITextField to "pop". The only one wired up to this is hashtag
 *
 *  @since 1.0
 */
- (void)popAnimation:(UITextField *)textField {
    textField.borderStyle = _twitterName.borderStyle;
    textField.backgroundColor = _twitterName.backgroundColor;
    
    CGFloat percent = 0.2; // Try 20%
    CGAffineTransform embiggen = CGAffineTransformMakeScale(1.0f + percent, 1.0f + percent);
    CGAffineTransform shrink   = CGAffineTransformMakeScale(1.0f / (1.0 + percent), 1.0f / (1.0 + percent));
    [UIView animateWithDuration:0.1f animations:^{
        textField.transform = embiggen;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1f animations:^{
                textField.transform = shrink;
            }];
        }
    }
     ];
}

/**
 *  Removes the leading "#" from a string
 *
 *  @param hashtag String which may/may not have a leading "#"
 *
 *  @return Input string without the leading "#" (if applicable)
 *
 *  @since 1.0
 */
- (NSString *)removeHash:(NSString *)hashtag {
    NSString *firstCharacter = [hashtag substringToIndex:1];
    if (![firstCharacter isEqualToString:@"#"]) {
        hashtag = [hashtag stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }
    
    return hashtag;
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
    BOOL dialogHasBeenPresented = [defaults boolForKey:@"dialogHasBeenPresented"];
    
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
    BOOL userDeniedPermission = [defaults boolForKey:@"userDeniedPermission"];
    
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
    BOOL userHasNoAccount = [defaults boolForKey:@"userHasNoAccount"];
    
    return userHasNoAccount;
}

/**
 *  Stores the entered hashtag (without the leading #) in user defaults, so it can be used later
 *
 *  @param hashtag Text from the hashtag field
 *
 *  @since 1.0
 */
- (void)saveHashtag:(NSString *)hashtag {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[self removeHash:hashtag] forKey:@"lastUsedHashtag"];
    [defaults synchronize];
}

/**
 *  Retrieves the last used hashtag from user defaults
 *
 *  @return The last used hashtag (without the leading #), or @""
 *
 *  @since 1.0
 */
- (NSString *)retrieveHashtag {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *hashtag = [defaults valueForKey:@"lastUsedHashtag"];
    if (hashtag) {
        return hashtag;
    }
    hashtag = @"";
    
    return hashtag;
}

#pragma mark - Protocol methods

- (void)displayInfo:(NSDictionary *)data {    
    // Initialise Results screen
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PDXResultsViewController *resultsViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Results"];
    
    resultsViewController.data = data;
    resultsViewController.parent = self;
    resultsViewController.hashtag = _hashtag.text;
    resultsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    // Display view
    [self presentViewController:resultsViewController animated:YES completion:nil];
}

/**
 *  Presents the pre-approval scene from the Main.storyboard
 *
 *  User will select one of three options, which will determine what happens next:
 *
 *  1. Use Twitter account - continues to retrieve information from Twitter
 *
 *  2. I don't have a Twitter account - presents a dialog saying we need a Twitter account to
 *     use this app
 *
 *  3. Do NOT use my Twitter account - presents a dialog saying we need a Twitter account to
 *     use this app
 *
 *  @since 1.0
 */
- (void)presentPreApprovalDialog {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PDXPreApprovalViewController *preApprovalViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"PreApproval"];
    
    preApprovalViewController.parent = self;
    [self presentViewController:preApprovalViewController animated:YES completion:nil];
}

@end
