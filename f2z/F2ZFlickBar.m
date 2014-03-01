//
//  F2ZFlickBar.m
//  f2z
//
//  Created by Kempei Igarashi on 2014/03/01.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "F2ZFlickBar.h"

const int BAR_X = 20;
const int BAR_WIDTH = 20;

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
    CALayer *customDrawn;
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

- (void) setPosition:(BOOL)animated
{
    if (animated) {
        int direction = -1;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        CGPoint origin = customDrawn.position;
        customDrawn.position = CGPointMake((_flickCount + 1) * BAR_WIDTH + 10, 35);
        if (origin.x < customDrawn.position.x) {
            direction = 1;
        }
        animation.fromValue = [NSValue valueWithCGPoint:origin];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(origin.x + (20 * direction), origin.y)];
        animation.duration = 0.5;
        animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.33 :1.77 :0.62 :0.78];
//        animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.13 :1.09 :0.41 :1.48];
        [customDrawn addAnimation:animation forKey:@"move"];
    } else {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
    }
    customDrawn.position = CGPointMake((_flickCount + 1) * BAR_WIDTH + 10, 35);
    if (!animated) {
        [CATransaction commit];
    }
    [customDrawn setNeedsDisplay];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    del = [[MyLayerDelegate alloc] init];

    customDrawn = [CALayer layer];
    customDrawn.bounds = CGRectMake(0, 0, BAR_WIDTH, 70);
    customDrawn.backgroundColor = [UIColor orangeColor].CGColor;
    [self setPosition:NO];
    //customDrawn.delegate = del;
    //customDrawn.masksToBounds = YES;
    [self.layer addSublayer:customDrawn];
    
    return self;
}

@end
