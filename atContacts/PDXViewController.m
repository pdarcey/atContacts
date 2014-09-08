//
//  PDXViewController.m
//  atContacts
//
//  Created by Paul Darcey on 7/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXViewController.h"

@interface PDXViewController ()

@end

@implementation PDXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
 *  Convenience method to retrieve data model from App Delegate
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
 *  Convenience method to retrieve Twitter Communicator from App Delegate
 *
 *  @return App's PDXTwitterCommunicator
 *
 *  @since 1.0
 */
- (PDXTwitterCommunicator *)twitter {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    PDXTwitterCommunicator *twitter = [appDelegate twitter];
    
    return twitter;
}


@end
