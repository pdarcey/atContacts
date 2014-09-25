//
//  ResultsViewController.m
//  atContacts
//
//  Created by Paul Darcey on 1/09/2014.
//  © 2014 Paul Darcey. All rights reserved.
//

#import "PDXResultsViewController.h"

@interface PDXResultsViewController ()

@end

@implementation PDXResultsViewController

/**
 *  Initialise data that was set in the data property immediately after the view controller was created
 *
 *  Data cannot be allocated to fields in the view before this point or it will cause a crash!
 *
 *  @since 1.0
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
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
    // Set user info
    _firstName.text = [data valueForKey:kPersonFirstName];
    _lastName.text = [data valueForKey:kPersonLastName];
    _twitterHandle.text = [data valueForKey:kPersonTwitterName];
    _email.text = [data valueForKey:kPersonEmailAddress];
    _phone.text = [data valueForKey:kPersonPhoneNumber];
    _webAddress.text = [data valueForKey:kPersonWebAddress];
    _idString = [data valueForKey:kPersonIDString];

    // Set user photo
    NSString *photoURL = [data valueForKey:kPersonPhotoURL];
    [self getPhoto:photoURL];
    
    // Combine hashtag and description (if they exist)
    NSString *dataDescription = [data valueForKey:kPersonTwitterDescription];
    NSString *combinedHashtagAndDescription = kBlankString;

    if (_hashtag && ![_hashtag isEqualToString:kBlankString]) {
        combinedHashtagAndDescription = _hashtag;

        if (dataDescription && ![dataDescription isEqualToString:kBlankString]) {
            combinedHashtagAndDescription = [combinedHashtagAndDescription stringByAppendingString:[NSString stringWithFormat:@"\n%@", dataDescription]];
        }
        
    } else if (dataDescription && ![dataDescription isEqualToString:kBlankString]) {
        combinedHashtagAndDescription = dataDescription;
    }
    _twitterDescription.text = combinedHashtagAndDescription;

    // Set Following status
    NSNumber *following = [data valueForKey:kPersonFollowing];
    _following = [following boolValue];
    [self followedOnTwitter:_following];
    
    // Set Contacts status
    [self setContactState];
    
    // Set other elements to hidden
    _indicator.hidden = YES;
    _blurOverlay.hidden = YES;
    _errorMessage.hidden = YES;
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
        // We bypass this by removing the "_normal" part of the URL; this should return the original-sized version of the image
        NSString *largePhotoURL = [photoURL stringByReplacingOccurrencesOfString:@"_normal" withString:kBlankString];
        
        PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
        twitter.delegate = self;
        [twitter getUserImage:largePhotoURL];
    }
}

#pragma mark - Worker methods

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
 *  Returns a dictionary suitable to send to PDXContactMaker
 *
 *  @return A dictionary suitable to send to PDXContactMaker
 *
 *  @since 1.0
 */
- (NSDictionary *)personData {
    NSDictionary *personData = @{ kPersonFirstName    : _firstName.text,
                                  kPersonLastName     : _lastName.text,
                                  kPersonTwitterName  : _twitterHandle.text,
                                  kPersonEmailAddress : _email.text,
                                  kPersonPhoneNumber : _phone.text,
                                  kPersonWebAddress   : _webAddress.text,
                                  kPersonTwitterDescription : _twitterDescription.text,
                                  kPersonPhotoData    : UIImageJPEGRepresentation(_photo.image, 1.0f)
                                  };
    
    return personData;
}

#pragma mark - Protocol methods for PDXTwitterCommunicatorDelegate

/**
 *  Sets the Twitter button. If user already follows person, displays the highlighted button and disables button
 *
 *  Called by PDXTwitterCommunicator when it receives an answer from Twitter
 *
 *  @param success YES if the user already follows the person, NO if they do not
 *
 *  @since 1.0
 */
- (void)followedOnTwitter:(BOOL)success {
    if (success) {
        NSString *message = NSLocalizedString(@"Followed on Twitter", @"Display result of hitting Twitter button");
        [self displayErrorMessage:message];
        [self setButtonHighlighted:YES button:_twitterButton message:message];
        [self setBothButtonEnabled];
    }
}

/**
 *  Animates the display of the person's image when it is received (which will be immediately after the other details are displayed)
 *
 *  @param image Image returned by Twitter of the person's profile picture
 *
 *  @since 1.0
 */
- (void)displayUserImage:(UIImage *)image {
    CGFloat duration = 1.2;

    dispatch_async(dispatch_get_main_queue(), ^{
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{_photo.image = image;}
                     completion:nil
     ];
    });
}

#pragma mark - Protocol methods for PDXContactMakerDelegate

/**
 *  Sets the Contacts button upon creaton of person, displays the highlighted button and disables button
 *
 *  @param success YES is the person was successfully created, NO if not
 *
 *  @since 1.0
 */
- (void)newContactMade:(BOOL)success {
    if (success) {
        NSString *message = NSLocalizedString(@"Added to Contacts", @"Display result of hitting Contacts button");
        [self setButtonHighlighted:YES button:_contactsButton message:message];
        [self displayErrorMessage:message];
        [self setBothButtonEnabled];
    }
}

#pragma mark - Protocol methods for both PDXTwitterCommunicatorDelegate and PDXContactMakerDelegate

/**
 *  Display a message to the user. Animates a fade in/fade out effect
 *
 *  Required by PDXTwitterCommunicatorDelegate protocol
 *
 *  Fade in & fade out time are each set as animationDuration
 *  Display time is set as displayTime
 *  (i.e. total animation time = 2 x animationDuration + displayDuration)
 *
 *  @param message The message to be displayed
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

#pragma mark - Button actions

/**
 *  When user taps on the Twitter button, follow the person on Twitter
 *
 *  @param sender Will always be twitterButton
 *
 *  @since 1.0
 */
- (IBAction)followOnTwitter:(UIButton *)sender {
    PDXTwitterCommunicator *twitter = [PDXTwitterCommunicator new];
    twitter.delegate = self;
    
    if (!_following) {
        [twitter follow:[_data valueForKey:kPersonFollowing]];
    } else {
        // This should never be displayed as the button should not be enabled
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Already following %@ on Twitter", @"Trying to follow someone we already follow"), _twitterHandle];
        [self displayErrorMessage:message];
    }
}

/**
 *  Uses PSXContactMaker to check whether a person with the same name as the person already exists in Contacts
 *
 *  Sets the Contact button's state based on the result of that check
 *
 *  @since 1.0
 */
- (void)setContactState {
    // Set Contacts status
    PDXContactMaker *contacts = [PDXContactMaker new];
    contacts.delegate = self;

    if ([contacts isInContacts:[self personData]]) {
        NSString *message = NSLocalizedString(@"Person is in Contacts", @"Display contact state");
        [self setButtonHighlighted:YES button:_contactsButton message:message];
        [self setBothButtonEnabled];
    }
}

/**
 *  When user taps on the Contacts button, add the person's details to the user's Contacts
 *
 *  @since 1.0
 */
- (IBAction)addToContacts {
    PDXContactMaker *contactMaker = [PDXContactMaker new];
    contactMaker.delegate = self;
    NSDictionary *personData = [self personData];
    
    [contactMaker addToContacts:personData];
}

/**
 *  Equivalent of tapping both the twitterButton and the contactButton
 *
 *  @param sender Will always be the bothButton
 *
 *  @since 1.0
 */
- (IBAction)followAndAdd:(UIButton *)sender {
    [self followOnTwitter:sender];
    [self addToContacts];
}

/**
 *  Sets the Both button to enabled if either the Twitter button or the Contacts button is enabled
 *
 *  @since 1.0
 */
- (void)setBothButtonEnabled {
    BOOL enabled = (_twitterButton.enabled || _contactsButton.enabled);
    NSString *message = NSLocalizedString(@"Person is in Contacts and followed on Twitter", @"Set both contact state");
    [self setButtonHighlighted:enabled button:_bothButton message:message];
}

/**
 *  Sets a button to remain highlighted and be disabled
 *
 *  @param highlighted YES sets the button to highlighted and disables the button; NO has no effect
 *  @param button      Which button to set
 *
 *  @since 1.0
 */
- (void)setButtonHighlighted:(BOOL)highlighted button:(UIButton *)button message:(NSString *)message {
    if (highlighted) {
        [button setImage:[button imageForState:UIControlStateHighlighted] forState:UIControlStateDisabled];
        button.enabled = NO;
        button.accessibilityHint = message;
    }
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
    if ([textField.restorationIdentifier isEqualToString:kFakeTextField]) {
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
    fakeTextField.restorationIdentifier = kFakeTextField;
    
    // Set it to the same frame as the caller
    fakeTextField.frame = realTextField.frame;
    fakeTextField.borderStyle = UITextBorderStyleRoundedRect;
    fakeTextField.backgroundColor = [UIColor kAppOrangeColor];
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
    
    // Add accessibility traits
    fakeTextField.accessibilityLabel = realTextField.accessibilityLabel;
    fakeTextField.accessibilityHint = realTextField.accessibilityHint;
    
    // Add to view
    [self.view addSubview:fakeTextField];

    // Move it into position
    [self moveTextFieldToOverlay:fakeTextField];
    
}

#pragma mark - Animations

/**
 *  Makes the selected UITextField "pop" - i.e. momentarily get larger, then revert to its original size
 *
 *  @param textField UITextField selected by the user by tapping on it
 *
 *  @since 1.0
 */
- (void)popAnimation:(UITextField *)textField {
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.backgroundColor = [UIColor kAppOrangeColor];

    CGFloat percent = 0.2; // Try 20%
    CGAffineTransform embiggen = CGAffineTransformMakeScale(1.0f + percent, 1.0f + percent);
    CGAffineTransform shrink   = CGAffineTransformMakeScale(1.0f / (1.0 + percent), 1.0f / (1.0 + percent));
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
}

/**
 *  Instead of moving a selected UITextField for editing, we create a fake copy of it, and move it into place over a blur effect
 *
 *  Displays a blur effect over the whole screen, upon which we will edit the selected field
 *
 *  @since 1.0
 */
- (void)showBlurOverlay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.8 animations:^{
            _blurOverlay.hidden = NO;
        }];
    });
}

/**
 *  Hides the blur effect when we are done with editing
 *
 *  @since 1.0
 */
- (void)hideBlurOverlay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.8 animations:^{
            _blurOverlay.hidden = YES;
        }];
    });
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.7 animations:^{
            textField.center = newCenter;
            NSString *accessibilityNotification = [NSString stringWithFormat:NSLocalizedString(@"Displaying keyboard and moving %@ field above it", @"Accessibility announcement when moving input field"), textField.description];
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, accessibilityNotification);
        } completion:^(BOOL finished) {
            if (finished) {
                [textField becomeFirstResponder];
                NSString *accessibilityNotification = [NSString stringWithFormat:NSLocalizedString(@"%@ field is ready for input", @"Accessibility announcement that input field has stopped moving"), textField.description];
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, accessibilityNotification);
            }
        }];
    });
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
 
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.7 animations:^{
            // Move
            textField.center = newCenter;
            NSString *accessibilityNotification = [NSString stringWithFormat:NSLocalizedString(@"Removing keyboard and moving %@ field back to its original position", @"Accessibility announcement when moving input field back"), textField.description];
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, accessibilityNotification);
        } completion:^(BOOL finished) {
            if (finished) {
                _realTextField.text = textField.text;
                [UIView animateWithDuration:0.3 animations:^{
                    textField.alpha = 0;
                } completion:^(BOOL finished) {
                    if (finished) {
                        [textField removeFromSuperview];
                    }
                }];
            }
        }];
    });
}

# pragma mark - Notification Center Notifications

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    _twitterHandle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _email.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _phone.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _webAddress.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _twitterDescription.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _errorMessage.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [self.view setNeedsLayout];
}

@end

