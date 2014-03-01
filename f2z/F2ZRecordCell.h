//
//  F2ZRecordCell.h
//  f2z
//
//  Created by Kempei Igarashi on 2014/02/23.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "F2ZFlickBar.h"

@interface F2ZRecordCell : UITableViewCell

- (void) incrementFlickCount; // animated
- (void) decrementFlickCount; // animated

@property (nonatomic) NSInteger flickCount;
@property (nonatomic) UInt16 amount;
@property (nonatomic) NSString *date;
@property (nonatomic) NSString *station;
@property (nonatomic) NSString *line;
@property (nonatomic) NSString *flickCountComment;

@property (weak, nonatomic) IBOutlet F2ZFlickBar *flickBar;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *flickCountCommentLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@end
