//
//  F2ZFlickBar.h
//  f2z
//
//  Created by Kempei Igarashi on 2014/03/01.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyLayerDelegate : NSObject
@property (nonatomic) NSInteger flickCount;
@end

@interface F2ZFlickBar : UIView

@property (nonatomic) NSInteger flickCount;
@property (nonatomic) CAGradientLayer *backGroundLayer;

- (void) increment;
- (void) decrement;

@end
