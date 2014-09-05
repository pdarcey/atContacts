//
//  ResultsViewController.m
//  atContacts
//
//  Created by Paul Darcey on 1/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "ResultsViewController.h"

@interface ResultsViewController ()

@end

@implementation ResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set values from data
    PDXDataModel *data = [self data];
    
    _firstName.text = data.firstName;
    _lastName.text = data.lastName;
    NSString *photoURL = data.photoURL;
    [self getPhoto:photoURL];
    _twitterHandle.text = data.twitterName;
    _email.text = data.emailAddress;
    _phone.text = data.phoneNumber;
    _webAddress.text = data.wwwAddress;
    NSString *combinedHashtagAndDescription = @"";
    if (data.hashtag && ![data.hashtag isEqualToString:@""]) {
        combinedHashtagAndDescription = data.hashtag;
        if (data.twitterDescription && ![data.twitterDescription isEqualToString:@""]) {
            [combinedHashtagAndDescription stringByAppendingString:[NSString stringWithFormat:@"\n%@", data.twitterDescription]];
        }
    } else if (data.twitterDescription && ![data.twitterDescription isEqualToString:@""]) {
            combinedHashtagAndDescription = data.twitterDescription;
    }
    _twitterDescription.text = combinedHashtagAndDescription;
    if (data.alreadyFollow) {
        <#statements#>
    }
    _indicator.hidden = YES;
    _blurOverlay.hidden = YES;
}

#pragma mark - Download Photo

- (void)getPhoto:(NSString *)photoURL  {
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

- (PDXDataModel *)data {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    PDXDataModel *data = [appDelegate data];
    
    return data;
}

- (UITextField *)currentTextField {
    NSArray *subviews = self.view.subviews;
    for (UIView *subview in subviews) {
        if ((subview.class == [UITextField class]) && [subview isFirstResponder]) {
            return (UITextField *)subview;
        }
    }
    return nil;
}

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

#pragma mark - Button actions

- (IBAction)followOnTwitter:(UIButton *)sender {
    NSLog(@"followOnTwitter button selected");
}

- (IBAction)addToContacts:(UIButton *)sender {
    NSLog(@"followOnTwitter button selected");
}

- (IBAction)followAndAdd:(UIButton *)sender {
    NSLog(@"followAndAdd button selected");
    [self followOnTwitter:sender];
    [self addToContacts:sender];
}

#pragma mark - Swipe & Tap actions

- (IBAction)swipeToDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapToEndEditing {
    UITextField *textField = [self currentTextField];
    [textField resignFirstResponder];
    [self textFieldDidEndEditing:textField];
}

#pragma mark - Text view editing

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (_blurOverlay.hidden) {
        [self showBlurOverlay];
        [self makeFakeTextField:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.restorationIdentifier isEqualToString:@"fakeTextField"]) {
        [self moveTextFieldFromOverlay:textField];
        [self hideBlurOverlay];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Remove keyboard & send message textFieldDidEndEditing
    [textField resignFirstResponder];
    return YES;
}

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
    
    // Add to view
    [self.view addSubview:fakeTextField];

    // Move it into position
    [self moveTextFieldToOverlay:fakeTextField];
    
}

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

- (void)showBlurOverlay {
    [UIView animateWithDuration:0.8 animations:^{
        _blurOverlay.hidden = NO;
    }];
}

- (void)hideBlurOverlay {
    [UIView animateWithDuration:0.8 animations:^{
        _blurOverlay.hidden = YES;
    }];
}

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

