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

//                 UIImage *image = [UIImage imageWithData:data];


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
    _hashtag.text = data.hashtag;
    _firstName.text = data.firstName;
    _lastName.text = data.lastName;
    _photo.image = [UIImage imageWithData:data.photoData];
    _twitterHandle.text = data.twitterName;
    _email.text = data.emailAddress;
    _phone.text = data.phoneNumber;
    _webAddress.text = data.wwwAddress;
    _twitterDescription.text = [NSString stringWithFormat:@"%@\n\n%@", data.hashtag, data.twitterDescription];
    _indicator.hidden = YES;

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

@end
