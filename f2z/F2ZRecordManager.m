//
//  F2ZRecordManager.m
//  f2z
//
//  Created by Kempei Igarashi on 2014/02/26.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import "F2ZRecordManager.h"
#import "FMDatabase.h"

NS_ENUM(NSInteger, F2ZOpType) {
    F2ZOpTypeRail,
    F2ZOpTypeBus,
    F2ZOpTypeShop
};

@implementation F2ZRecordManager
{
    FMDatabase *db;
    NSMutableDictionary *dict;
    NSMutableDictionary *linedict;
    
    NSDictionary *operationDict;
    NSDictionary *operationTypeDict;
    NSDictionary *paymentTypeDict;
    NSDictionary *vendorTypeDict;
    NSDictionary *entryTypeDict;
}

- (id) init
{
    dict = [[NSMutableDictionary alloc] init];
    linedict = [[NSMutableDictionary alloc] init];
    operationDict = @{@0x01:@"", // 自動改札機出場
                      @0x02:@"チャージ", // SFチャージ
                      @0x03:@"きっぷ購入",
                      @0x04:@"磁気券精算",
                      @0x05:@"乗越精算",
                      @0x06:@"窓口出場",
                      @0x07:@"新規",
                      @0x08:@"控除",
                      @0x0D:@"バス等均一運賃",
                      @0x0F:@"バス等",
                      @0x11:@"再発行",
                      @0x13:@"料金出場",
                      @0x14:@"オートチャージ",
                      @0x1F:@"バス等チャージ",
                      @0x46:@"物販",
                      @0x48:@"ポイントチャージ",
                      @0x4B:@"入場・物販"};
    operationTypeDict = @{@0x01:@(F2ZOpTypeRail),
                          @0x02:@(F2ZOpTypeRail),
                          @0x03:@(F2ZOpTypeRail),
                          @0x04:@(F2ZOpTypeRail),
                          @0x05:@(F2ZOpTypeRail),
                          @0x06:@(F2ZOpTypeRail),
                          @0x07:@(F2ZOpTypeRail),
                          @0x08:@(F2ZOpTypeRail),
                          @0x0D:@(F2ZOpTypeBus),
                          @0x0F:@(F2ZOpTypeBus),
                          @0x11:@(F2ZOpTypeRail),
                          @0x13:@(F2ZOpTypeRail),
                          @0x14:@(F2ZOpTypeRail),
                          @0x1F:@(F2ZOpTypeBus),
                          @0x46:@(F2ZOpTypeShop),
                          @0x48:@(F2ZOpTypeShop),
                          @0x4B:@(F2ZOpTypeShop)};
    paymentTypeDict = @{@0x00:@"", // 現金 / なし
                        @0x02:@"VIEW",
                        @0x0B:@"PiTaPa",
                        @0x0D:@"オートチャージ対応PASMO",
                        @0x3F:@"モバイルSuica(VIEW決済以外)"};
    vendorTypeDict = @{@0x03:@"精算機",
                       @0x04:@"携帯端末",
                       @0x05:@"バス等車載機",
                       @0x07:@"カード発売機",
                       @0x08:@"自動券売機",
                       @0x09:@"SMART ICOCA",
                       @0x12:@"自動券売機(東京モノレール)",
                       @0x14:@"駅務機器",
                       @0x15:@"定期券発売機",
                       @0x16:@"自動改札機",
                       @0x17:@"簡易改札機",
                       @0x18:@"駅務機器",
                       @0x19:@"窓口処理機(みどりの窓口)",
                       @0x1A:@"窓口処理機(有人改札)",
                       @0x1B:@"モバイルFeliCa",
                       @0x1C:@"入場券券売機",
                       @0x1D:@"他社乗換自動改札機",
                       @0x1F:@"入金機",
                       @0x20:@"発行機",  //(モノレール)
                       @0x22:@"簡易改札機", //(ことでん)
                       @0x34:@"カード発売機", //(せたまる?)
                       @0x35:@"バス等車載機", //(せたまる車内入金機??)
                       @0x36:@"バス等車載機(車内簡易改札機)",
                       @0x46:@"ビューアルッテ端末",
                       @0xC7:@"物販端末",
                       @0xC8:@"物販端末"};
    entryTypeDict = @{@0x01:@"入場",
                      @0x02:@"入場/出場",
                      @0x03:@"定期入場/出場",
                      @0x04:@"入場/定期出場",
                      @0x0E:@"窓口出場",
                      @0x0F:@"入場/出場(バス等)",
                      @0x12:@"料金定期入場/料金出場",
                      @0x17:@"入場/出場(乗継割引)",
                      @0x21:@"入場/出場(バス等乗継割引)"};

    NSError* error = nil;
    NSString* work_path;
    NSString* database_filename;
    
    NSString* database_path;
    NSString* template_path;
    
    database_filename = @"code.db";
    work_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    database_path = [NSString stringWithFormat:@"%@/%@", work_path, database_filename];
    
    // 文書フォルダーにデータベースファイルが存在しているかを確認します。
    NSFileManager* manager = [NSFileManager defaultManager];
    //[manager removeItemAtPath:database_path error:&error]; // for new db
    if (![manager fileExistsAtPath:database_path])
    {
        // 文書フォルダーに存在しない場合は、データベースの複製元をバンドルから取得します。
        template_path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:database_filename];
        // バンドルから取得したデータベースファイルを文書フォルダーにコピーします。
        LogDebug(@"reading database file ...");
        if (![manager copyItemAtPath:template_path toPath:database_path error:&error])
        {
            [NSException raise:@"IOException"
                        format:@"failure in copuItemAtPath() [%@] -> [%@]", template_path, database_path
             ];
        }
    }
    LogDebug(@"opening database ...");
    db = [FMDatabase databaseWithPath:database_path];
    [db open];

    return self;
}

- (NSString *) lineFromBytes: (UInt16) r
                    areacode: (UInt8)area
{
    UInt8 r1 = r >> 8;
    NSString *linecode = [NSString stringWithFormat:@"%d", area * 256 + r1];
    LogTrace(@"checking areacode/linecode [%d/%@] ...", area, linecode);
    NSString *line = [linedict objectForKey:linecode];
    if (line == nil) {
        [self stationFromBytes:r areacode:area];
        line = [linedict objectForKey:linecode];
    }
    return line;
}

- (NSString *) stationFromBytes: (UInt16) r
                       areacode: (UInt8)area
{
    UInt8 r1 = r >> 8;
    UInt8 r2 = r & 0xFF;
    NSString *linecode = [NSString stringWithFormat:@"%d", area * 256 + r1];
    NSString *stationcode = [NSString stringWithFormat:@"%d", r2];
    LogTrace(@"checking areacode/linecode/stationcode [%d/%@/%@] ...", area, linecode, stationcode);
    NSMutableDictionary *subdict;
    NSString *_line = nil;
    subdict = [dict objectForKey:linecode];
    if (subdict == nil) {
        subdict = [[NSMutableDictionary alloc] init];
        LogDebug(@"querying database (areacode/linecode) = (%d/%d) ...", area, r1);
        FMResultSet *results =
        [db executeQuery:@"select stationcode, stationname, linename from stationcode where areacode = ? and linecode = ?",
         [NSNumber numberWithInt:area], [NSNumber numberWithInt:r1]];
        while( [results next] )
        {
            if (_line == nil) {
                _line = [results stringForColumnIndex:2];
                [linedict setValue:_line forKey:linecode];
            }
            NSString *_stationcode = [NSString stringWithFormat:@"%d", [results intForColumnIndex:0]];
            NSString *_station = [results stringForColumnIndex:1];
            LogTrace(@"adding station [%@/%@] ...", _stationcode, _station);
            [subdict setValue:_station forKey:_stationcode];
        }
        [dict setValue:subdict forKey:linecode];
    }
    return [subdict objectForKey:stationcode];
}

- (NSString *) vendorType:(F2ZRecord*)record
{
    return [vendorTypeDict objectForKey:[NSNumber numberWithChar:[record vendorTypeRaw]]];
}

- (NSString *) operationType:(F2ZRecord*)record
{
    return [operationDict objectForKey:[NSNumber numberWithChar:[record operationTypeRaw]]];
}

- (NSString *) paymentType:(F2ZRecord*)record
{
    return [paymentTypeDict objectForKey:[NSNumber numberWithChar:[record paymentTypeRaw]]];
}

- (NSString *) entryType:(F2ZRecord*)record
{
    return [entryTypeDict objectForKey:[NSNumber numberWithChar:[record entryTypeRaw]]];
}

- (NSString *) operationDate:(F2ZRecord*)record
{
    return [NSString stringWithFormat:@"%d月%d日", [record month], [record day]];
}

- (NSString *) station:(F2ZRecord*)record
{
    NSString *station1;
    NSString *station2;
 
    switch ([[operationTypeDict objectForKey:[NSNumber numberWithChar:[record operationTypeRaw]]] integerValue]) {
        case F2ZOpTypeRail:
            if ([record station1Raw] > 0) {
                station1 = [self stationFromBytes:[record station1Raw] areacode:[record area1]];
                if ([record station2Raw] > 0) {
                    station2 = [self stationFromBytes:[record station2Raw] areacode:[record area2]];
                    return [NSString stringWithFormat:@"%@▷%@", station1, station2];
                } else {
                    return station1;
                }
            } else if ([record station2Raw] > 0) {
                station2 = [self stationFromBytes:[record station2Raw] areacode:[record area2]];
                return station2;
            } else {
                return @"";
            }
                
        case F2ZOpTypeBus:
            return @"";
            
        case F2ZOpTypeShop:
            return @"";
    }
    [NSException raise:@"RecordException"
                format:@"failure in switch:%@", record];
    return nil;
}

- (NSString *) line:(F2ZRecord *)record
{
    NSString *line1;
    NSString *line2;
    NSString *operationType = [self operationType:record];
    if (! [operationType isEqualToString:@""]) {
        operationType = [NSString stringWithFormat:@"%@,", operationType];
    }
    
    switch ([[operationTypeDict objectForKey:[NSNumber numberWithChar:[record operationTypeRaw]]] integerValue]) {
        case F2ZOpTypeRail:
            if ([record station1Raw] > 0) {
                line1 = [self lineFromBytes:[record station1Raw] areacode:[record area1]];
                if ([record station2Raw] > 0) {
                    line2 = [self lineFromBytes:[record station2Raw] areacode:[record area2]];
                    return [NSString stringWithFormat:@"%@%@▷%@", operationType, line1, line2];
                } else {
                    return [NSString stringWithFormat:@"%@%@", operationType, line1];
                }
            } else if ([record station2Raw] > 0) {
                line2 = [self lineFromBytes:[record station2Raw] areacode:[record area2]];
                return [NSString stringWithFormat:@"%@%@", operationType, line2];
            } else {
                return operationType;
            }
            
        case F2ZOpTypeBus:
            return operationType;
            
        case F2ZOpTypeShop:
            return operationType;
    }
    [NSException raise:@"RecordException"
                format:@"failure in switch:%@", record];
    return nil;
}

@end
