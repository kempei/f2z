//
//  F2ZCategory.m
//  f2z
//
//  Created by Kempei Igarashi on 2014/03/08.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import "F2ZCategory.h"

static NSArray *cats;
static NSUserDefaults *defaults;

@implementation F2ZCategory

+ (void)initialize
{
    // defaultsから取得するようにする
    cats = [defaults objectForKey:@"category"];
    if (cats == nil) {
        // 初期値
        cats = @[[[F2ZCategory alloc]
                  initWithValues: @"未精算/非同期"
                  where: nil
                  why: nil
                  projectNo: nil
                  taskNo: nil
                  expenseType: F2ZCategoryExpenseTypeNone
                  flags: F2ZCategoryFlagNone],
                 [[F2ZCategory alloc]
                  initWithValues: @"プライベート"
                  where: @"各所"
                  why: @"色々"
                  projectNo: nil
                  taskNo: nil
                  expenseType: F2ZCategoryExpenseTypeNone
                  flags: F2ZCategoryFlagZaim],
                 [[F2ZCategory alloc]
                  initWithValues: @"定期外交通費"
                  where: @"会社"
                  why: nil
                  projectNo: nil
                  taskNo: nil
                  expenseType: F2ZCategoryExpenseTypeNone
                  flags: F2ZCategoryFlagZaim],
                 [[F2ZCategory alloc]
                  initWithValues: @"本社間移動"
                  where: @"ACB/OAC"
                  why: @"各種打ち合わせ"
                  projectNo: @"300393728"
                  taskNo: @"2.2"
                  expenseType: F2ZCategoryExpenseTypeProject
                  flags: F2ZCategoryFlagExpense],
                 [[F2ZCategory alloc]
                  initWithValues: @"NTTコミュニケーションズ問い合わせ支援システム"
                  where: @"NTTコミュニケーションズ本社"
                  why: @"コンサルプリセールス"
                  projectNo: @"300393734"
                  taskNo:@"2.2_MK"
                  expenseType: F2ZCategoryExpenseTypeProject
                  flags: F2ZCategoryFlagExpense],
                 [[F2ZCategory alloc]
                  initWithValues: @"航空局システム"
                  where: @"NTTデータ築地"
                  why: @"コンサルプリセールス"
                  projectNo: @"300393734"
                  taskNo:@"2.2_MK"
                  expenseType: F2ZCategoryExpenseTypeProject
                  flags: F2ZCategoryFlagExpense],
                 [[F2ZCategory alloc]
                  initWithValues: @"札幌市役所様プリセールス"
                  where: @"札幌市役所"
                  why: @"Exalogicプリセールス"
                  projectNo: @"300393734"
                  taskNo:@"2.2_MK"
                  expenseType: F2ZCategoryExpenseTypeProject
                  flags: F2ZCategoryFlagExpense],
                 [[F2ZCategory alloc]
                  initWithValues: @"未精算/非同期"
                  where: @""
                  why: @""
                  projectNo: @""
                  taskNo:@"2.2_MK"
                  expenseType: F2ZCategoryExpenseTypeProject
                  flags: F2ZCategoryFlagExpense],
                 [[F2ZCategory alloc]
                  initWithValues: nil
                  where: nil
                  why: nil
                  projectNo: nil
                  taskNo: nil
                  expenseType: F2ZCategoryExpenseTypeNone
                  flags: F2ZCategoryFlagNone],
                 [[F2ZCategory alloc]
                  initWithValues: nil
                  where: nil
                  why: nil
                  projectNo: nil
                  taskNo: nil
                  expenseType: F2ZCategoryExpenseTypeNone
                  flags: F2ZCategoryFlagNone]];
    }
}

- (id)initWithValues: (NSString*)name
               where: (NSString*)where
                 why: (NSString*)why
           projectNo: (NSString*)projectNo
              taskNo: (NSString*)taskNo
         expenseType: (NSInteger)expenseType
               flags: (UInt32)flags
{
    self = [super init];
    _title = name;
    _where = where;
    _why = why;
    _projectNo = projectNo;
    _taskNo = taskNo;
    _expenseType = expenseType;
    _flags = flags;
    return self;
}

+ (F2ZCategory*) category:(NSInteger)flickCount
{
    return cats[flickCount];
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    LogTrace(@"encode category");
    [encoder encodeObject:_title forKey:@"name"];
    [encoder encodeObject:_where forKey:@"where"];
    [encoder encodeObject:_why forKey:@"why"];
    [encoder encodeObject:_projectNo forKey:@"projectNo"];
    [encoder encodeObject:_taskNo forKey:@"taskNo"];
    [encoder encodeInteger:_expenseType forKey:@"expenseType"];
    [encoder encodeInt32:_flags forKey:@"flags"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    LogTrace(@"decode category");
    self = [super init];
    _title = [decoder decodeObjectForKey:@"name"];
    _where = [decoder decodeObjectForKey:@"where"];
    _why = [decoder decodeObjectForKey:@"why"];
    _projectNo = [decoder decodeObjectForKey:@"projectNo"];
    _taskNo = [decoder decodeObjectForKey:@"taskNo"];
    _expenseType = [decoder decodeIntegerForKey:@"expenseType"];
    _flags = [decoder decodeInt32ForKey:@"flags"];
    return self;
}


@end
