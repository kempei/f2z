//
//  F2ZRecordCell.m
//  f2z
//
//  Created by Kempei Igarashi on 2014/02/23.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import "F2ZRecordCell.h"

static NSNumberFormatter *formatter;

@implementation F2ZRecordCell

+ (void) initialize
{
    formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
    formatter.currencySymbol = @"¥";
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
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

- (void)setFlickCount:(NSInteger)flickCount
{
    _flickCount = flickCount;
    _flickBar.flickCount = _flickCount;
}

- (void)setFlickCountComment:(NSString *)flickCountComment
{
    _flickCountComment = flickCountComment;
    [_flickCountCommentLabel setText:_flickCountComment];
}

- (void) setDate:(NSString *)date
{
    _date = date;
    [_dateLabel setText:_date];
}

- (void) setAmount:(UInt16)amount
{
    _amount = amount;
    [_amountLabel setText:[formatter stringFromNumber:[[NSNumber alloc] initWithInteger:_amount]]];
}

- (void) setStation:(NSString *)station
{
    _station = station;
    [_stationLabel setText:_station];
}

- (void) setLine:(NSString *)line
{
    _line = line;
    [_lineLabel setText: _line];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
