//
//  F2ZRecordCell.h
//  f2z
//
//  Created by Kempei Igarashi on 2014/02/23.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "F2ZFlickBarCell.h"
#import "F2ZRecord.h"

@interface F2ZHistoryRecordCell : F2ZFlickBarCell

+ (NSNumberFormatter*)formatter;

@property (nonatomic) F2ZRecord *record;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@property (weak, nonatomic) IBOutlet UILabel *categoryTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *whereWhyLabel;

@end
