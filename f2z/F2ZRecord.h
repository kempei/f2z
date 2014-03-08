//
//  F2ZRecord.h
//  f2z
//
//  Created by Kempei Igarashi on 2014/02/23.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "F2ZCategory.h"

@interface F2ZRecord : NSObject <NSCoding>

typedef NS_OPTIONS(NSUInteger, F2ZRecordFlag) {
    F2ZRecordFlagNone        = 0,
    F2ZRecordFlagExpense     = 1 << 0,
    F2ZRecordFlagZaim        = 1 << 1,
    F2ZRecordFlagEditable    = 1 << 2,
    F2ZRecordFlagEdited      = 1 << 3,
    F2ZRecordFlagExpenseDone = 1 << 4,
    F2ZRecordFlagZaimDone    = 1 << 5
};

@property(nonatomic) NSInteger flicks;
@property(nonatomic) NSInteger usage; //使用金額

- (id) initWithRawdata: (Byte *)data
                offset: (NSUInteger)offset;
- (void) setRawdata: (Byte *) data
             offset: (NSUInteger)offset;

- (UInt8)   vendorTypeRaw;    //機器種別
- (UInt8)   operationTypeRaw; //利用種別
- (UInt8)   paymentTypeRaw;   //支払種別
- (UInt8)   entryTypeRaw;     //入出場種別
- (UInt16)  station1Raw;      //入場駅[電車] 事業者コード[バス] 時分秒[物販]
- (UInt16)  station2Raw;      //出場駅[電車] 停留所コード[バス] 端末コード[物販]
- (UInt8)   year;             //処理日付(年)
- (UInt8)   month;            //処理日付(月)
- (UInt8)   day;              //処理日付(日)
- (UInt16)  amount;           //残額
- (UInt16)  scn;              //取引通番
- (UInt8)   area1;            //地域コード(入場駅) 電車のみ
- (UInt8)   area2;            //地域コード(出場駅) 電車のみ

/////////from category
- (NSString*) where;          //カスタムで入力したwhereがあればそれ、なければカテゴリのもの
- (NSString*) why;            //カスタムで入力したwhereがあればそれ、なければカテゴリのもの
- (NSString*) categoryTitle;

@end
