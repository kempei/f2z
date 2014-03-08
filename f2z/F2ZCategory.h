//
//  F2ZCategory.h
//  f2z
//
//  Created by Kempei Igarashi on 2014/03/08.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(UInt32, F2ZCategoryFlag) {
    F2ZCategoryFlagNone       = 0,
    F2ZCategoryFlagExpense    = 1 << 0,
    F2ZCategoryFlagZaim       = 1 << 1
};

typedef NS_ENUM(NSInteger, F2ZCategoryExpenseType) {
    F2ZCategoryExpenseTypeNone,
    F2ZCategoryExpenseTypeGeneral,
    F2ZCategoryExpenseTypeProject
};

const static NSInteger MAX_CATEGORIES = 9;

@interface F2ZCategory : NSObject <NSCoding>

+ (F2ZCategory*) category:(NSInteger)flickCount;

@property(nonatomic) NSString *title;
@property(nonatomic) NSString *why;
@property(nonatomic) NSString *where;
@property(nonatomic) NSString *projectNo; //Generalの場合はOPP#
@property(nonatomic) NSString *taskNo;

@property(nonatomic) F2ZCategoryFlag flags;
@property(nonatomic) F2ZCategoryExpenseType expenseType;

@end
