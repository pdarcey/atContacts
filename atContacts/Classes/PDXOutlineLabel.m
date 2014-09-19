//
//  PDXOutlineLabel.m
//  atContacts
//
//  Created by Paul Darcey on 19/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import "PDXOutlineLabel.h"

@implementation PDXOutlineLabel

- (void)drawTextInRect:(CGRect)rect {
    
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(context, kCGTextStroke);
    self.textColor = self.outlineColor;
    [super drawTextInRect:rect];
    
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    self.textColor = textColor;
    [[UIColor clearColor] setStroke]; // invisible stroke
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
    
    self.shadowOffset = shadowOffset;
    
}
@end
