//
//  PDXMessageView.m
//  @Contacts
//
//  Created by Paul Darcey on 7/10/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXMessageView.h"

@implementation PDXMessageView

- (instancetype)initWithMessage:(NSString *)message {
    self = [super init];
    
    if (self) {
        // Set up default color, size, and make into rounded rect
        self.backgroundColor = [UIColor clearColor];
        [self setAutoresizesSubviews:NO];
        self.layer.bounds = CGRectMake(0, 0, 400, 400); // Default size. Will be adjusted by constraints below
        self.layer.masksToBounds = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Add Rounded Rect
        UIView *blackBackground = [UIView new];
        _background = blackBackground;
        _background.backgroundColor = [[UIColor kAppBlackColor] colorWithAlphaComponent:0.5];
        _background.layer.frame = CGRectMake(10, 10, 390, 200); // Default size. Will be adjusted by constraints below
        _background.layer.cornerRadius = 6;
        _background.layer.masksToBounds = NO;
        _background.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Add shadow
        _background.layer.shadowColor = [[UIColor blackColor] CGColor];
        _background.layer.shadowOffset = CGSizeMake(0, 5);
        _background.layer.shadowOpacity = 0.25;
        [self addSubview:_background];
        
        // Add label, format it, and set its contents
        UILabel *messageLabel = [UILabel new];
        _message = messageLabel;
        [_message setAutoresizesSubviews:NO];
        _message.frame = CGRectInset(_background.bounds, 26, 26);
        _message.layer.masksToBounds = YES;
        _message.backgroundColor = [UIColor clearColor];
        _message.textColor = [UIColor kAppWhiteColor];
        _message.textAlignment = NSTextAlignmentCenter;
        _message.text = message;
        _message.adjustsFontSizeToFitWidth = NO;
        _message.numberOfLines = 0;
        _message.lineBreakMode = NSLineBreakByWordWrapping;
        _message.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _message.translatesAutoresizingMaskIntoConstraints = NO;
        [_message sizeToFit];

        [_background addSubview:_message];
        [self resize:_background toFit:_message margin:6];
        [self resize:self toFit:_background margin:6];
        [_background sizeToFit];
        [self sizeToFit];
        
        // [self centerMessageInView:self];
    }
    
    return self;
}

- (void)resize:(UIView *)superview toFit:(UIView *)subview margin:(CGFloat)margin {
    if (!margin) {
        margin = 0;
    }
    superview.layer.bounds = CGRectUnion(superview.layer.bounds, CGRectOffset(subview.layer.frame, margin * 2, margin * 2));
    superview.layer.bounds = CGRectMake(0, 0, superview.layer.bounds.size.width, superview.layer.bounds.size.height);
    subview.layer.frame = CGRectMake((superview.layer.bounds.size.width - subview.layer.bounds.size.width) / 2, margin, subview.layer.bounds.size.width, subview.layer.bounds.size.height);
    
}

- (void)centerMessageInView:(UIView *)view {
    NSArray *constraints = @[
                             // Align message horizontally
                             [NSLayoutConstraint constraintWithItem:_message
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_background
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0],
                             // Align message vertically
                             [NSLayoutConstraint constraintWithItem:_message
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_background
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0],
                             // Align background horizontally
                             [NSLayoutConstraint constraintWithItem:_background
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0],
                             // Align background vertically
                             [NSLayoutConstraint constraintWithItem:_background
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]
//                             // Set width
//                             [NSLayoutConstraint constraintWithItem:_message
//                                                          attribute:NSLayoutAttributeWidth
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self
//                                                          attribute:NSLayoutAttributeWidth
//                                                         multiplier:1
//                                                           constant:-6],
//                             // Set Min height
//                             [NSLayoutConstraint constraintWithItem:_message
//                                                          attribute:NSLayoutAttributeHeight
//                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
//                                                             toItem:nil
//                                                          attribute:NSLayoutAttributeNotAnAttribute
//                                                         multiplier:1
//                                                           constant:200],
//                             // Set Min height
//                             [NSLayoutConstraint constraintWithItem:_message
//                                                          attribute:NSLayoutAttributeHeight
//                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
//                                                             toItem:nil
//                                                          attribute:NSLayoutAttributeNotAnAttribute
//                                                         multiplier:1
//                                                           constant:_message.layer.bounds.size.height]
                             ];
    [self addConstraints:constraints];
    [self setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisVertical];
    [self setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
    [self updateConstraints];
    
}

- (BOOL)translatesAutoresizingMaskIntoConstraints {
    return NO;
}

@end
