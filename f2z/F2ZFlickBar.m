//
//  F2ZFlickBar.m
//  f2z
//
//  Created by Kempei Igarashi on 2014/03/01.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "F2ZFlickBar.h"
#import "UIColor+iOS7Colors.h"


const int BAR_ADJUST_X = 10;
const int BAR_WIDTH = 30;
const int BAR_HEIGHT = 80;

@implementation MyLayerDelegate
- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context
{
//    CGContextSetRGBFillColor(context, 0.0, 1.0, 1.0, 1.0);
//    CGContextFillRect(context, CGRectMake(0,0, BAR_WIDTH, 70));
}
@end

@implementation F2ZFlickBar
{
    MyLayerDelegate *del;
    CAGradientLayer *rectLayer;
    
    NSArray *colorPallete;
}

- (void) increment
{
    _flickCount++;
    [self setPosition:YES];
}

- (void) decrement
{
    _flickCount--;
    [self setPosition:YES];
}

- (void) setFlickCount:(float)flickCount
{
    _flickCount = flickCount;
    del.flickCount = flickCount;
    [self setPosition:NO];
}

- (void) setPosition_
{
    rectLayer.position = CGPointMake((_flickCount + 1) * BAR_WIDTH + BAR_WIDTH/2 - BAR_ADJUST_X, BAR_HEIGHT/2);
    rectLayer.colors = [colorPallete objectAtIndex:_flickCount+1];
}

- (void) setPosition:(BOOL)animated
{
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        CGPoint origin = rectLayer.position;
        [self setPosition_];
        animation.fromValue = [NSValue valueWithCGPoint:origin];
        animation.toValue = [NSValue
                             valueWithCGPoint:CGPointMake(origin.x +
                                                          (BAR_WIDTH * (origin.x < rectLayer.position.x ? 1 : -1)),
                                                          origin.y)];
        animation.duration = 0.8;
        animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.33 :1.77 :0.62 :0.78];
        [rectLayer addAnimation:animation forKey:@"move"];
    } else {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        [self setPosition_];
        [CATransaction commit];
    }
    [rectLayer setNeedsDisplay];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    colorPallete = @[[UIColor iOS7silverGradient],
                     [UIColor iOS7greenGradient],
                     [UIColor iOS7orangeGradient],
                     [UIColor iOS7bluegreenGradient],
                     [UIColor iOS7yellowGradient],
                     [UIColor iOS7magenta2Gradient],
                     [UIColor iOS7red2Gradient],
                     [UIColor iOS7tealGradient],
                     [UIColor iOS7grayGradient],
                     [UIColor iOS7magentaGradient]
                     ];
    
    //del = [[MyLayerDelegate alloc] init];
    //rectLayer.delegate = del;
    rectLayer = [CAGradientLayer layer];
    rectLayer.bounds = CGRectMake(0, 0, BAR_WIDTH, BAR_HEIGHT + BAR_WIDTH/2); // init
    [self setPosition:NO];
    [self.layer addSublayer:rectLayer];
    
    return self;
}

@end
