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
        self.backgroundColor = [[UIColor kAppBlackColor] colorWithAlphaComponent:0.5];
        self.layer.bounds = CGRectMake(0, 0, 200, 100); // Default size. Will be adjusted by constraints below
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = NO;
        
        // Add shadow
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0, 5);
        self.layer.shadowOpacity = 0.25;
        
        // Add label, format it, and set its contents
        UILabel *messageLabel = [UILabel new];
        _message = messageLabel;
        _message.backgroundColor = [UIColor clearColor];
        _message.textColor = [UIColor kAppWhiteColor];
        _message.text = message;
        _message.adjustsFontSizeToFitWidth = NO;
        _message.numberOfLines = 0;
        _message.lineBreakMode = NSLineBreakByWordWrapping;
        _message.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        CGFloat margin = 3;
        _message.preferredMaxLayoutWidth = self.layer.bounds.size.width - (margin * 2);
        
        [_message sizeToFit];
        NSLog(@"_message size: width: %f x height: %f", _message.layer.bounds.size.width, _message.layer.bounds.size.height);

        [self addSubview:_message];
        [self sizeToFit];
        NSLog(@"MessageView size: width: %f x height: %f", self.layer.bounds.size.width, self.layer.bounds.size.height);
        
        [self centerMessageInView:self];
        // [self addMaskToView:self];
        // [self addShadowToView:self];
    }
    
    return self;
}

- (void)centerMessageInView:(UIView *)view {
    NSArray *constraints = @[
                             // Align horizontally
                             [NSLayoutConstraint constraintWithItem:_message
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0],
                             // Align vertically
                             [NSLayoutConstraint constraintWithItem:_message
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0],
                             // Set width
                             [NSLayoutConstraint constraintWithItem:_message
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:-6],
                             // Set Min height
                             [NSLayoutConstraint constraintWithItem:_message
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:200],
                             // Set Min height
                             [NSLayoutConstraint constraintWithItem:_message
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:_message.layer.bounds.size.height],
                             // Align vertically
                             [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                             toItem:_message
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1
                                                           constant:6]

                             ];
    
    [self addConstraints:constraints];
    [self setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisVertical];
    [self setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
    [self sizeToFit];

}

@end
