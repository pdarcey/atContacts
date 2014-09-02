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
    NSString *lastHashtagUsed = data.hashtag;
    _hashtag.text = lastHashtagUsed;
    [_twitterName setText:@""];
    [_twitterName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)findTwitterName:(id)sender {
    NSLog(@"findTwitterName called\n");
    
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
    NSLog(@"touchDownOutsideFields called\n");
    [self endHashtagEditing:nil];
}

#pragma mark - Hashtag editing

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing called\n");
    if (textField == _twitterName) {
        [self findTwitterName:nil];
    } else if (textField == _hashtag) {
        [self endHashtagEditing:textField];
    }
    
    return YES;
}

- (IBAction)startHashtagEditing:(id)sender {
    NSLog(@"testHashtagEditing called\n");
    _hashtag.borderStyle = _twitterName.borderStyle;
    _hashtag.backgroundColor = _twitterName.backgroundColor;

}

- (IBAction)endHashtagEditing:(id)sender {
    NSLog(@"finishedTestHashtagEditing called\n");
    _hashtag.borderStyle = UITextBorderStyleNone;
    _hashtag.backgroundColor = [UIColor clearColor];
    if (_hashtag.text.length > 0) {
        NSString *firstCharacter = [_hashtag.text substringToIndex:1];
        if (![firstCharacter isEqualToString:@"#"]) {
            _hashtag.text = [@"#" stringByAppendingString:_hashtag.text];
        }
    }
    [_twitterName becomeFirstResponder];
    
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
