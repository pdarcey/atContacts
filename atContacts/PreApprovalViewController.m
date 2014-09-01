//
//  PreApprovalViewController.m
//  atContacts
//
//  Created by Paul Darcey on 29/08/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PreApprovalViewController.h"

@interface PreApprovalViewController ()

@end

@implementation PreApprovalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)permissionGranted:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"dialogHasBeenPresented"];
    [defaults setBool:NO forKey:@"userDeniedPermission"];
    [defaults setBool:NO forKey:@"userHasNoAccount"];
    [self dismissViewController];
}

- (IBAction)permissionDenied:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"dialogHasBeenPresented"];
    [defaults setBool:YES forKey:@"userDeniedPermission"];
    [defaults setBool:NO forKey:@"userHasNoAccount"];
    [self dismissViewController];
}

- (IBAction)noTwitterAccount:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"dialogHasBeenPresented"];
    [defaults setBool:NO forKey:@"userDeniedPermission"];
    [defaults setBool:YES forKey:@"userHasNoAccount"];
    [self dismissViewController];
}

- (void)dismissViewController {
    [self.nameFinder retrieveInformation];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
