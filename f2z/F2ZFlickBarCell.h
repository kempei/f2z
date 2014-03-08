//
//  F2ZFlickBarCell.h
//  f2z
//
//  Created by Kempei Igarashi on 2014/03/08.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "F2ZFlickBar.h"

typedef NS_ENUM(NSInteger, F2ZRecordCellColor) {
    F2ZRecordCellSelectColor,
    F2ZRecordCellCategoryColor,
    F2ZRecordCellCancelColor
};

@interface F2ZFlickBarCell : UITableViewCell

+ (NSArray*) colorPalleteAtIndex:(NSInteger)index;

- (void) incrementFlickCount;
- (void) decrementFlickCount;
- (void) changeBackGround:(F2ZRecordCellColor)colorType;

@property (nonatomic) NSInteger flickCount;
@property (weak, nonatomic) IBOutlet F2ZFlickBar *flickBar;

@end
