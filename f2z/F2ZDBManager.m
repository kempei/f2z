//
//  F2ZDBManager.m
//  f2z
//
//  Created by Kempei Igarashi on 2014/03/02.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import "F2ZDBManager.h"
#import "FMDatabase.h"

static NSMutableDictionary *dbDict;

@implementation F2ZDBManager

+(void)initialize
{
    dbDict = [[NSMutableDictionary alloc] init];
}

+ (FMDatabase*)db:(NSString*)name
{
    FMDatabase *db = [dbDict objectForKey:name];
    if (db == nil) {
        NSError *error;
        NSString *work_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *database_path = [NSString stringWithFormat:@"%@/%@.db", work_path, name];
        
        // 文書フォルダーにデータベースファイルが存在しているかを確認します。
        NSFileManager* manager = [NSFileManager defaultManager];
        //[manager removeItemAtPath:database_path error:&error]; // for new db
        if (![manager fileExistsAtPath:database_path])
        {
            // 文書フォルダーに存在しない場合は、データベースの複製元をバンドルから取得します。
            NSString *template_path = [[[NSBundle mainBundle] resourcePath]
                                       stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", name]];
            // バンドルから取得したデータベースファイルを文書フォルダーにコピーします。
            LogDebug(@"reading database file ...");
            if (![manager copyItemAtPath:template_path toPath:database_path error:&error])
            {
                [NSException raise:@"IOException"
                            format:@"failure in copyItemAtPath() [%@] -> [%@]", template_path, database_path
                 ];
            }
        }
        LogDebug(@"opening database ...");
        db = [FMDatabase databaseWithPath:database_path];
        [db open];
        
        /*
        if ([name isEqual:@"history"]) {
            [db executeUpdate:
             @"create table if not exists history (scn integer not null, year integer, month integer, day integer, data);"];
            [db executeUpdate:@"create index history_idx on history (scn);"];
        }
         */
        
        [dbDict setObject:db forKey:name];
    }
    return db;
}

@end
