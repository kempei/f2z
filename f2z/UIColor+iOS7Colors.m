#import "UIColor+iOS7Colors.h"

#define colorFromInteger(Color) [UIColor               \
colorWithRed:((Color & 0xFF0000) >> 16) / 255.0    \
green:((Color & 0xFF00) >> 8) / 255.0              \
blue:(Color & 0xFF) / 255.0                        \
alpha:1]

#define gradientPair(name, start, end)                                              \
+ (instancetype)iOS7##name##GradientStartColor { return colorFromInteger(start); }  \
+ (instancetype)iOS7##name##GradientEndColor { return colorFromInteger(end); }      \
+ (NSArray *)iOS7##name##Gradient { return @[(id)UIColor.iOS7##name##GradientStartColor.CGColor, (id)UIColor.iOS7##name##GradientEndColor.CGColor]; }

@implementation UIColor (iOS7Colors)

+ (NSArray *)iOS7GradientPairs
{
    return @[
             [self.class iOS7redGradient],
             [self.class iOS7orangeGradient],
             [self.class iOS7yellowGradient],
             [self.class iOS7greenGradient],
             [self.class iOS7tealGradient],
             [self.class iOS7blueGradient],
             [self.class iOS7violetGradient],
             [self.class iOS7magentaGradient],
             [self.class iOS7charcoalGradient],
             [self.class iOS7silverGradient],
             ];
}

+ (NSArray *)iOS7Colors
{
    return @[
             [self.class iOS7greenColor],
             [self.class iOS7tealColor],
             [self.class iOS7yellowColor],
             [self.class iOS7magentaColor],
             [self.class iOS7charcoalColor],
             [self.class iOS7blueColor],
             [self.class iOS7lightGreyColor],
             [self.class iOS7violetColor],
             [self.class iOS7yellowColor],
             [self.class iOS7redColor],
             [self.class iOS7darkGreyColor],
             ];
}

+ (instancetype)iOS7redColor { return colorFromInteger(0xFF3B30); }
+ (instancetype)iOS7orangeColor { return colorFromInteger(0xFF9500); }
+ (instancetype)iOS7yellowColor { return colorFromInteger(0xFFCC00); }
+ (instancetype)iOS7greenColor { return colorFromInteger(0x4CD964); }
+ (instancetype)iOS7tealColor { return colorFromInteger(0x34AADC); }
+ (instancetype)iOS7blueColor { return colorFromInteger(0x007AFF); }
+ (instancetype)iOS7violetColor { return colorFromInteger(0x5856D6); }
+ (instancetype)iOS7magentaColor { return colorFromInteger(0xFF2D55); }
+ (instancetype)iOS7darkGreyColor { return colorFromInteger(0x8E8E93); }
+ (instancetype)iOS7lightGreyColor { return colorFromInteger(0xC7C7CC); }
+ (instancetype)iOS7charcoalColor { return colorFromInteger(0x4A4A4A); }

gradientPair(red, 0xFF5E3A, 0xFF2A68)
gradientPair(orange, 0xFF9500, 0xFF5E3A)
gradientPair(yellow, 0xFFDB4C, 0xFFCD02)
gradientPair(green, 0x87FC70, 0x0BD318)
gradientPair(teal, 0x52EDC7, 0x5AC8FB)
gradientPair(blue, 0x1AD6FD, 0x1D62F0)
gradientPair(violet, 0xC644FC, 0x5856D6)
gradientPair(magenta, 0xEF4DB6, 0xC643FC)
gradientPair(charcoal, 0x4A4A4A, 0x2B2B2B)
gradientPair(silver, 0xDBDDDE, 0x898C90)

gradientPair(red2, 0xFB2B69, 0xFF5B37)
gradientPair(gray, 0xD6CEC3, 0xE4DDCA)
gradientPair(bluegreen, 0x55EFCB, 0x5BCAFF)
gradientPair(white, 0xF7F7F7, 0xD7D7D7)
gradientPair(blue2, 0x1D77EF, 0x81F3FD)
gradientPair(green2, 0x5AD427, 0xA4E786)
gradientPair(magenta2, 0xC86EDF, 0xE4B7F0)

@end

#undef gradientPair
#undef colorFromInteger