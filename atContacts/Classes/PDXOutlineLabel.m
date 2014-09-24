//
//  PDXOutlineLabel.m
//  atContacts
//
//  Created by Paul Darcey on 19/09/2014.
//  © 2014 Paul Darcey. All rights reserved.
//
// Subclass of PDXLabel which displays the label's text with a 1px outline in a color set by the label's
// newly-added property, outlineText.

#import "PDXOutlineLabel.h"

@implementation PDXOutlineLabel

/**
 *  Overrides default drawTextInRect to draw text in its textColor with a 1px outline in outlineColor
 *
 *  @param rect The rect in which to draw the text. This is set by the UILable
 *
 *  @since 1.0
 */
- (void)drawTextInRect:(CGRect)rect {
    
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(context, kCGTextStroke);
    self.textColor = [UIColor orangeColor];
    // self.textColor = self.outlineColor;
    [super drawTextInRect:rect];
    
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    self.textColor = textColor;
    [[UIColor clearColor] setStroke]; // invisible stroke
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
    
    self.shadowOffset = shadowOffset;
    
}

@end
