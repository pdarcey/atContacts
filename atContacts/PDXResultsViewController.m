//
//  ResultsViewController.m
//  atContacts
//
//  Created by Paul Darcey on 1/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXResultsViewController.h"

@interface PDXResultsViewController ()

@end

@implementation PDXResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self twitter] setDelegate:self.parent];
    [self initialiseData:_data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Initialise data fields

/**
 *  Sets up initial values to display for all fields, based on data dictionary passed in by the parent when the view is created
 *
 *  @since 1.0
 */
- (void)initialiseData:(NSDictionary *)data {
    
    _firstName.text = [data valueForKey:@"firstName"];
    _lastName.text = [data valueForKey:@"lastName"];
    NSString *photoURL = [data valueForKey:@"photoURL"];
    _twitterHandle.text = [data valueForKey:@"twitterName"];
    _email.text = [data valueForKey:@"emailAddress"];
    _phone.text = [data valueForKey:@"phoneNumber"];
    _webAddress.text = [data valueForKey:@"wwwAddress"];
    NSString *dataDescription = [data valueForKey:@"twitterDescription"];
    NSNumber *following= [data valueForKey:@"following"];
    [self toggleTwitter:[following boolValue]];
    
    [self getPhoto:photoURL];
    NSString *combinedHashtagAndDescription = @"";
    if (_hashtag && ![_hashtag isEqualToString:@""]) {
        combinedHashtagAndDescription = _hashtag;
        if (dataDescription && ![dataDescription isEqualToString:@""]) {
            combinedHashtagAndDescription = [combinedHashtagAndDescription stringByAppendingString:[NSString stringWithFormat:@"\n%@", dataDescription]];
        }
    } else if (dataDescription && ![dataDescription isEqualToString:@""]) {
        combinedHashtagAndDescription = dataDescription;
    }
    _twitterDescription.text = combinedHashtagAndDescription;
    _contactsButton.highlighted = NO;
    
    PDXTwitterCommunicator *twitter = [self twitter];
    twitter.delegate = self;
    _indicator.hidden = YES;
    _blurOverlay.hidden = YES;
    
}

/**
 *  Download the person's photo in the background, and display it when it becomes available
 *
 *  @param photoURL URL of photo to display. Comes from retrieved Twitter data
 *
 *  @since 1.0
 */
- (void)getPhoto:(NSString *)photoURL  {
    // By default, _photo.image shows the image pre-set in the storyboard, so no need to set a default image
    if (![photoURL isEqualToString:@""]) {
        
        // Twitter by default returns a photo URL that gives a low-rez version of the person's image
        // We bypass this by removing the "_normal" part of the URL; this should return the full-sized version of the image
        NSString *largePhotoURL = [photoURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:largePhotoURL]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    // TODO: Check NSURLResponse to ensure we received a valid response
                    _photo.image = [UIImage imageWithData:data];
                    
                }] resume];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

/**
 *  Works out which of the UITextFields is being edited
 *
 *  @return Pointer to the relevant UITextField
 *
 *  @since 1.0
 */
- (UITextField *)currentTextField {
    NSArray *subviews = self.view.subviews;
    for (UIView *subview in subviews) {
        if ((subview.class == [UITextField class]) && [subview isFirstResponder]) {
            return (UITextField *)subview;
        }
    }
    return nil;
}

/**
 *  A set of constraints used to display a UITextField for editing
 *
 *  @param textField The UITextField to use for editing
 *
 *  @return Array of contstraints to add to the relevant UITextField
 *
 *  @since 1.0
 */
- (NSArray *)newConstraints:(UITextField *)textField {
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:textField
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:0
                                                                    constant:textField.frame.size.width];
    
    NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:textField
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:0
                                                                    constant:textField.frame.size.height];
    
    NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:textField
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                    constant:0];
    
    NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:textField
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:-50];

    NSArray *newConstraints = @[constraint1, constraint2, constraint3, constraint4];
    
    return newConstraints;
}

#pragma mark - Protocol methods

- (void)toggleTwitter:(BOOL)onOff {
    _twitterButton.highlighted = onOff;
}

- (void)newContactMade:(BOOL)success {
    if (success) {
        [self showContactButtonResults:NSLocalizedString(@"Added to Contacts", @"Display result of hitting Contacts button")];
        _contactsButton.highlighted = YES;
    }
}

#pragma mark - Button actions

/**
 *  When user taps on the Twitter button, follow the person on Twitter
 *
 *  @param sender Will always be twitterButton
 *
 *  @since 1.0
 */
- (IBAction)followOnTwitter:(UIButton *)sender {
    NSLog(@"Twitter follow status = %hhd", sender.selected);
    if (sender.selected) {
        // Follow on Twitter
        PDXTwitterCommunicator *twitter = [self twitter];
        [twitter follow:[_data valueForKey:@"idString"]];
        [self showTwitterButtonResults:NSLocalizedString(@"Followed on Twitter", @"Display result of hitting Twitter button")];
        _twitterButton.highlighted = YES;
    } else {
        // Unfollow
        PDXTwitterCommunicator *twitter = [self twitter];
        [twitter unfollow:[_data valueForKey:@"idString"]];
        [self showTwitterButtonResults:NSLocalizedString(@"Unfollowed on Twitter", @"Display result of hitting Twitter button")];
        _twitterButton.highlighted = NO;
    }
}

/**
 *  When user taps on the Contacts button, add the person's details to the user's Contacts
 *
 *  @param sender Will always be the contactButton
 *
 *  @since 1.0
 */
- (IBAction)addToContacts {
    NSLog(@"addToContacts button selected");
    PDXContactMaker *contactMaker = [PDXContactMaker new];
    NSDictionary *personData = @{ @"firstName"    : _firstName.text,
                                  @"lastName"     : _lastName.text,
                                  @"twitterName"  : _twitterHandle.text,
                                  @"emailAddress" : _email.text,
                                  @"phoneNumber"  : _phone.text,
                                  @"wwwAddress"   : _webAddress.text,
                                  @"twitterDescription" : _twitterDescription.text,
                                  @"photoData"    : UIImageJPEGRepresentation(_photo.image, 1.0f)
                                 };
    
    contactMaker.delegate = self;
    [contactMaker addToContacts:personData];
}

/**
 *  Equivalent of pressing both the twitterButton and the contactButton
 *
 *  @param sender Will always be the bothButton
 *
 *  @since 1.0
 */
- (IBAction)followAndAdd:(UIButton *)sender {
    NSLog(@"followAndAdd button selected");
    [self followOnTwitter:sender];
    [self addToContacts];
}

#pragma mark - Swipe & Tap actions

/**
 *  Dismiss this view and return to the Input View
 *
 *  @since 1.0
 */
- (IBAction)swipeToDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  A tap outside the UITextField while editing is considered the equivalent of hitting the Return button
 *  This is *necessary* for the phone number keyboard, which lacks a Return button
 *
 *  @since 1.0
 */
- (IBAction)tapToEndEditing {
    UITextField *textField = [self currentTextField];
    [textField resignFirstResponder];
    [self textFieldDidEndEditing:textField];
}

#pragma mark - Text view editing

/**
 *  UITextField delegate method, called when user taps inside a UITextField
 *
 *  Because the textFields in this view controller would be under the keyboard, we blur the background and move
 *    the textField into a better position to edit it. (Actually, we create a fake copy, which gets edited.)
 *
 *  @param textField The UITextField the user tapped
 *
 *  @since 1.0
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (_blurOverlay.hidden) {
        [self showBlurOverlay];
        [self makeFakeTextField:textField];
    }
}

/**
 *  UITextField delegate method, called when user finishes editing a UITextField
 *
 *  Because the textFields in this view controller would be under the keyboard for editing, and we blur the background and move
 *  the textField into a better position to edit it, this method moves everything back to their original positions.
 *  (Actually, we create a fake copy, which gets edited, and move it back to the original position before dismissing it.)
 *
 *  @param textField The fake text field, which is being editied
 *
 *  @since 1.0
 */
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.restorationIdentifier isEqualToString:@"fakeTextField"]) {
        [self moveTextFieldFromOverlay:textField];
        [self hideBlurOverlay];
    }
}

/**
 *  UITextField delegate method, called when user hits Return in a UITextField
 *
 *  We always make this resign First Responder, which removes the keyboard from display, and calls textFieldDidEndEditing
 *
 *  @param textField The UITextField being edited
 *
 *  @return Always returns YES
 *
 *  @since 1.0
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Remove keyboard & send message textFieldDidEndEditing
    [textField resignFirstResponder];
    return YES;
}

/**
 *  Instead of moving a selected UITextField for editing, we create a fake copy of it, and move it into place over the blur effect
 *
 *  This saves us from having to screw around with the original textField's constraints.
 *
 *  @param realTextField The original textField selected by the user
 *
 *  @since 1.0
 */
- (void)makeFakeTextField:(UITextField *)realTextField {
    // Save the original caller
    _realTextField = realTextField;
    
    // Make the fake
    UITextField *fakeTextField = [UITextField new];
    fakeTextField.restorationIdentifier = @"fakeTextField";
    
    // Set it to the same frame as the caller
    fakeTextField.frame = realTextField.frame;
    fakeTextField.borderStyle = UITextBorderStyleRoundedRect;
    fakeTextField.backgroundColor = [UIColor orangeColor]; // TODO: Set this to application-specific orange tint
    fakeTextField.textColor = realTextField.textColor;
    fakeTextField.font = realTextField.font;
    fakeTextField.autocapitalizationType = realTextField.autocapitalizationType;
    fakeTextField.autocorrectionType = realTextField.autocorrectionType;
    fakeTextField.spellCheckingType = realTextField.spellCheckingType;
    fakeTextField.enablesReturnKeyAutomatically = realTextField.enablesReturnKeyAutomatically;
    fakeTextField.keyboardAppearance = realTextField.keyboardAppearance;
    fakeTextField.keyboardType = realTextField.keyboardType;
    fakeTextField.returnKeyType = realTextField.returnKeyType;
    fakeTextField.placeholder = realTextField.placeholder;
    fakeTextField.text = realTextField.text;
    fakeTextField.enablesReturnKeyAutomatically = realTextField.enablesReturnKeyAutomatically;
    fakeTextField.delegate = self;
    
    // Add to view
    [self.view addSubview:fakeTextField];

    // Move it into position
    [self moveTextFieldToOverlay:fakeTextField];
    
}

/**
 *  Makes the selected UITextField "pop" - i.e. momentarily get larger, then revert to its original size
 *
 *  @param textField UITextField selected by the user by tapping on it
 *
 *  @since 1.0
 */
- (void)popAnimation:(UITextField *)textField {
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.backgroundColor = [UIColor orangeColor]; // TODO: Set this to application-specific orange tint

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

- (void)showTwitterButtonResults:(NSString *)text {
    _followedOnTwitter.text = text;
    [self animateResultsButton:_followedOnTwitter];
}

- (void)showContactButtonResults:(NSString *)text {
    _addedToContacts.text = text;
    [self animateResultsButton:_addedToContacts];
}

- (void)animateResultsButton:(UILabel *)label {
    label.alpha = 0;
    label.hidden = NO;
    CGFloat duration = 3.1f;
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{label.alpha = 1;}
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:duration
                                               delay:0.0
                                             options: UIViewAnimationOptionCurveEaseOut
                                          animations:^{label.alpha = 0;}
                                          completion:^(BOOL finished) {
                                              label.hidden = YES;
                                          }
                          ];
                     }];
}

/**
 *  Instead of moving a selected UITextField for editing, we create a fake copy of it, and move it into place over a blur effect
 *
 *  Displays a blur effect over the whole screen, upon which we will edit the selected field
 *
 *  @since 1.0
 */
- (void)showBlurOverlay {
    [UIView animateWithDuration:0.8 animations:^{
        _blurOverlay.hidden = NO;
    }];
}

/**
 *  Hides the blur effect when we are done with editing
 *
 *  @since 1.0
 */
- (void)hideBlurOverlay {
    [UIView animateWithDuration:0.8 animations:^{
        _blurOverlay.hidden = YES;
    }];
}

/**
 *  Instead of moving a selected UITextField for editing, we create a fake copy of it, and move it into place over a blur effect
 *
 *  This is the animation for the move
 *
 *  @param textField The UITextField to move (i.e. the fake one we just created)
 *
 *  @since 1.0
 */
- (void)moveTextFieldToOverlay:(UITextField *)textField {
    // Change views
    [self.view insertSubview:textField aboveSubview:_blurOverlay];
    
    CGPoint newCenter = CGPointMake(textField.center.x, self.view.center.y - 100);
    
    [UIView animateWithDuration:0.7 animations:^{
        // Move
        textField.center = newCenter;
    } completion:^(BOOL finished) {
        if (finished) {
            [textField becomeFirstResponder];
        }
    }];
}

/**
 *  Instead of moving a selected UITextField for editing, we create a fake copy of it, and move it into place over a blur effect
 *
 *  This is the animation for the move back to its original position when we are finished with it
 *
 *  @param textField The UITextField to move (i.e. the fake one we just created)
 *
 *  @since 1.0
 */
- (void)moveTextFieldFromOverlay:(UITextField *)textField {
    CGPoint newCenter = CGPointMake(_realTextField.center.x, _realTextField.center.y);
    
    [UIView animateWithDuration:0.7 animations:^{
        // Move
        textField.center = newCenter;
    } completion:^(BOOL finished) {
        if (finished) {
            _realTextField.text = textField.text;
            // Reset colours
            textField.borderStyle = UITextBorderStyleNone;
            textField.backgroundColor = [UIColor clearColor];
            [textField removeFromSuperview];
        }
    }];
}

@end

