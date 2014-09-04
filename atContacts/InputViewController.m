//
//  ViewController.m
//  atContacts
//
//  Created by Paul Darcey on 27/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "InputViewController.h"
#import "PDXNameFinder.h"
#import "AppDelegate.h"

@interface InputViewController ()

@end

@implementation InputViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

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

- (IBAction)touchDownOutsideFields:(id)sender {
    [self endHashtagEditing:nil];
}

#pragma mark - Hashtag editing

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _twitterName) {
        [self findTwitterName:nil];
    } else if (textField == _hashtag) {
        [self endHashtagEditing:textField];
    }
    
    return YES;
}

- (IBAction)startHashtagEditing:(id)sender {
    [self popAnimation:sender];
}

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

- (PDXDataModel *)data {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    PDXDataModel *data = [appDelegate data];

    return data;
}

- (void)saveHashtag:(NSString *)hashtag {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    PDXDataModel *data = [appDelegate data];
    
    data.hashtag = [self removeHash:hashtag];

}

- (NSString *)removeHash:(NSString *)hashtag {
    NSString *firstCharacter = [hashtag substringToIndex:1];
    if (![firstCharacter isEqualToString:@"#"]) {
        hashtag = [hashtag stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }
    
    return hashtag;
}

@end
