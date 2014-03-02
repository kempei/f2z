//
//  F2ZFelicaReader.h
//  f2z
//
//  Created by Kempei Igarashi on 2014/02/22.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface F2ZFelicaReader : NSObject <UIAlertViewDelegate>

- (void)pollAndRead:(id)requester selector:(SEL)refreshSelector;

@end
