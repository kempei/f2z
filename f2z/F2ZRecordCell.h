//
//  F2ZRecordCell.h
//  f2z
//
//  Created by Kempei Igarashi on 2014/02/23.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface F2ZRecordCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *flickCount;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *paymentType;
@property (weak, nonatomic) IBOutlet UILabel *station1;
@property (weak, nonatomic) IBOutlet UILabel *station2;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UILabel *zaim;

@end
