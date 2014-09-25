//
//  UIColor+ColorAdditions.m
//  Pilgrim
//
//  Created by Paul Darcey on 25/09/2014.
//  Copyright © 2014 Paul Darcey. All rights reserved.
//

#import "UIColor+ColorAdditions.h"

@implementation UIColor (UIColorAdditions)

// App Standard Colors
+ (UIColor *) kAppOrangeColor {
    return [UIColor colorWithRed:0.965 green:0.639 blue:0.294 alpha:1.000];
}

+ (UIColor *) kAppYellowColor {
    return [UIColor colorWithRed:0.976 green:0.835 blue:0.408 alpha:1.000];
}

+ (UIColor *) kAppBlackColor {
    return [UIColor colorWithWhite:0.039 alpha:1.000];
}

+ (UIColor *) kAppWhiteColor {
    return [UIColor colorWithWhite:0.961 alpha:1.000];
}

// Application-specific tint colour
+ (UIColor *) kTintColor {
    return [UIColor kAppOrangeColor];
}

@end
