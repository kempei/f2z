//
//  F2ZRecordManager.h
//  f2z
//
//  Created by Kempei Igarashi on 2014/02/26.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "F2ZRecord.h"

@interface F2ZRecordManager : NSObject
- (NSString *) vendorType:(F2ZRecord*)record;    //機器種別
- (NSString *) operationType:(F2ZRecord*)record; //利用種別
- (NSString *) paymentType:(F2ZRecord*)record;   //支払種別
- (NSString *) entryType:(F2ZRecord*)record;     //入出場種別
- (NSString *) operationDate:(F2ZRecord*)record; //処理日付
- (NSString *) station:(F2ZRecord*)record;       //駅[電車] 路線[バス] "物品"[物販]
- (NSString *) line:(F2ZRecord*)record;          //路線[電車] ""[バス] ""[物販]

- (void) storeToDatabase:(F2ZRecord*)record;     //レコードをデータベースに格納
@end
