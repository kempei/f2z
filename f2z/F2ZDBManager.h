//
//  F2ZDBManager.h
//  f2z
//
//  Created by Kempei Igarashi on 2014/03/02.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface F2ZDBManager : NSObject

+ (FMDatabase*)db:(NSString*)name;

@end
