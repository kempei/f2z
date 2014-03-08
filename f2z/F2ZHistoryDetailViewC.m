//
//  F2ZHistoryDetailViewController.m
//  f2z
//
//  Created by Kempei Igarashi on 2014/02/27.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import "F2ZHistoryDetailViewC.h"

@interface F2ZHistoryDetailViewC ()

@end

@implementation F2ZHistoryDetailViewC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationItem.backBarButtonItem.title = @" ";
    self.navigationItem.hidesBackButton = NO;
    [self.navigationController setNavigationBarHidden:NO animated:animated]; // ナビゲーションバー表示
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:animated]; // ナビゲーションバー非表示
}


@end
