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
            [combinedHashtagAndDescription stringByAppendingString:[NSString stringWithFormat:@"\n\n%@", data.twitterDescription]];
        }
    } else if (data.twitterDescription && ![data.twitterDescription isEqualToString:@""]) {
            combinedHashtagAndDescription = data.twitterDescription;
    }
    _twitterDescription.text = combinedHashtagAndDescription;
    _indicator.hidden = YES;

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

#pragma mark - Swipe actions

- (IBAction)swipeToDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Text view editing

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // Change background (and size?)
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.backgroundColor = [UIColor orangeColor]; // TODO: Set this to application-specific orange tint
    [self popAnimation:textField];
    if (!_blurOverlay) {
        [self addBlurOverlay];
        [self moveTextFieldToOverlay:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_blurOverlay) {
        [self moveTextFieldFromOverlay:textField];
        [self removeBlurOverlay];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Remove keyboard & send message textFieldDidEndEditing
    [textField resignFirstResponder];
    return YES;
}

- (void)popAnimation:(UITextField *)textField {
    CGFloat percent = 0.2; // Try 20%
    CGAffineTransform embiggen = CGAffineTransformMakeScale(1.0f + percent, 1.0f + percent);
    CGAffineTransform shrink   = CGAffineTransformMakeScale(1.0f / (1.0 + percent), 1.0f / (1.0 + percent));
    [UIView animateWithDuration:0.1f animations:^{
        textField.transform = embiggen;
        NSLog(@"popAnimation\nEmbiggen: animated to frame: ( %f %f; %f %f)", textField.frame.origin.x, textField.frame.origin.y, textField.frame.size.width, textField.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1f animations:^{
                textField.transform = shrink;
                NSLog(@"popAnimation\nShrink: animated to frame: ( %f %f; %f %f)", textField.frame.origin.x, textField.frame.origin.y, textField.frame.size.width, textField.frame.size.height);
            }];
        }
    }
     ];
}

- (void)addBlurOverlay {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    CGRect blurFrame = self.view.frame;
    [blurEffectView setFrame:blurFrame];
    _blurOverlay = blurEffectView;
    [self.view addSubview:_blurOverlay];
    
//    [UIView animateWithDuration:3.0 animations:^{
//        [self.view addSubview:_blurOverlay];
//    }];
}

- (void)removeBlurOverlay {
    [UIView animateWithDuration:3.0 animations:^{
        [_blurOverlay removeFromSuperview];
    }];
    _blurOverlay = nil;
}

- (void)moveTextFieldToOverlay:(UITextField *)textField {
    // Change views
    [self.view insertSubview:textField aboveSubview:_blurOverlay];
    
}

- (void)moveTextFieldFromOverlay:(UITextField *)textField {
    // Change views
    [_blurOverlay removeFromSuperview];
    
    // Reset colours
    textField.borderStyle = UITextBorderStyleNone;
    textField.backgroundColor = [UIColor clearColor];
    
    // Reset constraints
    NSArray *allConstraints = textField.constraints;
    [textField removeConstraints:allConstraints];
    [textField addConstraints:_originalConstraints];
    _originalConstraints = nil;
    [textField setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:5.0 animations:^{
        // Move
        [textField updateConstraints];
    }];
}

@end

