//
//  ViewController.m
//  atContacts
//
//  Created by Paul Darcey on 27/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXInputViewController.h"
#import "PDXNameFinder.h"
#import "AppDelegate.h"

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
    
    PDXDataModel *data = [self data];
    _hashtag.text = data.hashtag;
    [_twitterName setText:@""];
    [_twitterName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

/**
 *  Takes name from twitterName field and tries to find information from Twitter for that user
 *
 *  @param sender What field triggered this. Will almost(?) always be by hitting Return in twitterName textField
 *
 *  @since 1.0
 */
- (IBAction)findTwitterName:(id)sender {    
//    self.activitySpinner.hidden = NO;
//    [activitySpinner startAnimating];
    
    // Ensure that user hasn't included the initial "@" in the user name
    if (_twitterName.text.length > 0) {
        NSString *name = _twitterName.text;
        NSString *firstCharacter = [name substringToIndex:1];
        if (![firstCharacter isEqualToString:@"@"]) {
            name = [name stringByReplacingOccurrencesOfString:@"@" withString:@""];
        }

        PDXNameFinder *nameFinder = [PDXNameFinder new];
        [nameFinder findName:name];
    } else {
        [_twitterName becomeFirstResponder];
    }
}

/**
 *  If user taps outside the editable fields, end editing in all fields and set twitterName to be the first responder
 *
 *  @param sender Not used; irrelevant
 *
 *  @since 1.0
 */
- (IBAction)touchDownOutsideFields:(id)sender {
    [self endHashtagEditing:nil];
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
        [self findTwitterName:nil];
    } else if (textField == _hashtag) {
        [self endHashtagEditing:textField];
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
 *
 *  @param sender Not used; irrelevent
 *
 *  @since 1.0
 */
- (IBAction)endHashtagEditing:(id)sender {
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

#pragma mark - Convenience methods

/**
 *  Convenience method to retrieve data model from User Defaults
 *
 *  @return Data model stored in User Defaults
 *
 *  @since 1.0
 */
- (PDXDataModel *)data {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    PDXDataModel *data = [appDelegate data];

    return data;
}

/**
 *  Stores the entered hashtag in the data model, so it can be used later by ResultsViewController
 *
 *  @param hashtag Text from the hashtag field
 *
 *  @since 1.0
 */
- (void)saveHashtag:(NSString *)hashtag {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    PDXDataModel *data = [appDelegate data];
    
    data.hashtag = [self removeHash:hashtag];

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

@end
