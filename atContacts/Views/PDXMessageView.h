//
//  PDXMessageView.h
//  @Contacts
//
//  Created by Paul Darcey on 7/10/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDXConstants.h"

@interface PDXMessageView : UIView

@property (strong, nonatomic) UILabel *message;

- (instancetype)initWithMessage:(NSString *)message;

@end
