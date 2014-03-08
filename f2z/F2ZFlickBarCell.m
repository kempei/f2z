//
//  F2ZFlickBarCell.m
//  f2z
//
//  Created by Kempei Igarashi on 2014/03/08.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import "F2ZFlickBarCell.h"
#import "UIColor+iOS7Colors.h"

static NSArray *colorPallete;

@implementation F2ZFlickBarCell

+ (void)initialize
{
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
}

+ (NSArray*) colorPalleteAtIndex:(NSInteger)index
{
    if (index < 0 || index >= colorPallete.count) {
        LogError(@"invalid index %d", index);
        return nil;
    }
    return colorPallete[index];
}

- (void) incrementFlickCount
{
    LogTrace(@"increment!");
    _flickCount++; //範囲チェックなし
    [_flickBar increment];
}

- (void) decrementFlickCount
{
    LogTrace(@"decrement!");
    _flickCount--; //範囲チェックなし
    [_flickBar decrement];
}

- (void)changeBackGround:(F2ZRecordCellColor)colorType
{
    switch (colorType) {
        case F2ZRecordCellSelectColor:
            self.flickBar.backGroundLayer.colors = [UIColor iOS7charcoalGradient];
            break;
            
        case F2ZRecordCellCancelColor:
            self.flickBar.backGroundLayer.colors = nil;
            //self.flickBar.backGroundLayer.backgroundColor = [UIColor whiteColor].CGColor;
            break;
            
        case F2ZRecordCellCategoryColor:
            self.flickBar.backGroundLayer.colors = colorPallete[_flickCount+1];
            break;
            
        default:
            [NSException raise:@"IllegalStateException"
                        format:@"unknown F2ZRecordCellColor:%d", colorType];
    }
}

- (void)setFlickCount:(NSInteger)flickCount
{
    _flickCount = flickCount;
    _flickBar.flickCount = _flickCount;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
