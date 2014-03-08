//
//  F2ZRecordCell.m
//  f2z
//
//  Created by Kempei Igarashi on 2014/02/23.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "F2ZHistoryRecordCell.h"
#import "F2ZRecordManager.h"
#import "UIColor+iOS7Colors.h"


static F2ZRecordManager *rm;
static NSNumberFormatter *formatter;

@implementation F2ZHistoryRecordCell
{
    // DBにアクセスが必要な項目はキャッシュしておく
    NSString *dateCache;
    NSString *stationCache;
    NSString *lineCache;
}

+ (void) initialize
{
    formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
    formatter.currencySymbol = @"¥";
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    rm = [[F2ZRecordManager alloc] init];
}

+ (NSNumberFormatter*)formatter
{
    return formatter;
}

- (void) incrementFlickCount
{
    [super incrementFlickCount];
    [self refreshTexts:YES];
}

- (void) decrementFlickCount
{
    [super decrementFlickCount];
    [self refreshTexts:YES];
}

- (void) setRecord:(F2ZRecord *)record
{
    _record = record;
    dateCache = [rm operationDate:_record];
    stationCache = [rm station:_record];
    lineCache = [rm line:_record];
    [self setFlickCount:[_record flicks]];
    [self refreshTexts:NO];
}

- (void) refreshTexts:(BOOL)categoryAnimated
{
    if (categoryAnimated) {
        CATransition *fadeAnim = [CATransition animation];
        [fadeAnim setType:kCATransitionFade];
        [fadeAnim setDuration:0.3f];
        [_categoryTitleLabel.layer addAnimation:fadeAnim forKey:nil];
        [_whereWhyLabel.layer addAnimation:fadeAnim forKey:nil];
    }
    [_dateLabel setText:dateCache];
    if (stationCache && ![stationCache isEqual:@""]) {
        [_stationLabel setText:stationCache];
    } else {
        [_stationLabel setText:[rm operationType:_record]];
    }
    
    [_amountLabel setText:[formatter stringFromNumber:[[NSNumber alloc] initWithInteger:[_record usage]]]]; // 使用金額
    //[_lineLabel setText: lineCache];
    [_lineLabel setText: @""]; //こっちのほうがすっきりしている気がする
    [_categoryTitleLabel setText:[_record categoryTitle]];
    
    NSString *where = [_record where];
    NSString *why = [_record why];
    if (where) {
        if (why) {
            [_whereWhyLabel setText:[NSString stringWithFormat:@"%@ %@", where, why]];
        } else {
            [_whereWhyLabel setText:[NSString stringWithFormat:@"%@", where]];
        }
    } else if (why) {
        [_whereWhyLabel setText:[NSString stringWithFormat:@"%@", why]];
    } else {
        [_whereWhyLabel setText:@""];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
