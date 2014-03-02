//
//  F2ZHistoryViewController.m
//  f2z
//
//  Created by Kempei Igarashi on 2014/02/23.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import "F2ZHistoryViewController.h"
#import "F2ZRecordCell.h"
#import "F2ZRecord.h"
#import "F2ZFelicaReader.h"
#import "F2ZRecordManager.h"
#import "F2ZDBManager.h"
#import "FMDatabase.h"

@implementation F2ZHistoryViewController
{
    //NSUserDefaults *defaults;
    NSMutableArray *history;
    F2ZRecordManager *rm;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)refreshHistoryFromCard
{
    LogDebug(@"refresh history ...");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        LogDebug(@"dispatcher start ...");
        @autoreleasepool {
            F2ZFelicaReader *reader = [[F2ZFelicaReader alloc] init];
            [reader pollAndRead:self selector:@selector(refreshFromStoredData:)];
        }
    });
}

- (void)refreshFromStoredData:(NSNumber*) shouldRefresh
{
    if ([shouldRefresh boolValue]) {
        [history removeAllObjects];
        FMDatabase *db = [F2ZDBManager db:@"history"];
        FMResultSet *rs = [db executeQuery:@"select data from history order by year, month, day, scn"];
        while ([rs next]) {
            [history addObject:
             [NSKeyedUnarchiver unarchiveObjectWithData:
              [rs dataForColumnIndex:0]]];
        }
        [rs close];

        LogDebug(@"card history is loaded %@", history);
        [self.tableView reloadData];
    } else {
        LogDebug(@"nothing update.");
    }
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    //defaults = [NSUserDefaults standardUserDefaults];
    rm = [[F2ZRecordManager alloc] init];
    history = [[NSMutableArray alloc] init];

    [self.refreshControl addTarget:self
                            action:@selector(refreshHistoryFromCard)
                  forControlEvents:UIControlEventValueChanged];
    [self refreshFromStoredData:@YES];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UISwipeGestureRecognizer* swipeGesture =
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self action:@selector(didSwipeCell:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:swipeGesture];
    
    swipeGesture =
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self action:@selector(didSwipeCell:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipeGesture];
}

- (void) didSwipeCell:(UISwipeGestureRecognizer*)swipeRecognizer
{
    CGPoint loc = [swipeRecognizer locationInView:self.tableView];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:loc];
    F2ZRecordCell *cell = (F2ZRecordCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    NSUInteger row = history.count - indexPath.row;
    F2ZRecord *r = [history objectAtIndex:row];
   
    if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        if (r.flicks < 8) {
            r.flicks++;
            [cell incrementFlickCount];
        }
    } else if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (r.flicks > -1) {
            r.flicks--;
            [cell decrementFlickCount];
        }
    }
    
    LogTrace(@"swipe -> store: %@", r);
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:r];
    
    FMDatabase *db = [F2ZDBManager db:@"history"];
    BOOL rc = [db executeUpdate:@"update history set data=? where scn=? and day=? and month=? and year=?",
               data,
               [NSNumber numberWithInteger:[r scn]],
               [NSNumber numberWithUnsignedChar:[r day]],
               [NSNumber numberWithUnsignedChar:[r month]],
               [NSNumber numberWithUnsignedChar:[r year]]];
    
    if (rc != 1) {
        [NSException raise:@"DatabaseException"
                    format:@"failure in updating swiped record:%@", r];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (history != nil) {
        return history.count + 1;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"record";
    F2ZRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    if (indexPath.row == 0) {
        F2ZRecord *r = [history lastObject];
        cell.flickCount = -2; // 非表示
        cell.date = @"";
        cell.line = @"";
        cell.station = @"残額";
        cell.flickCountComment = @"";
        cell.amount = [r amount];
    } else {
        NSInteger row = history.count - indexPath.row;
        F2ZRecord *r = [history objectAtIndex:row];
        
        cell.flickCount         = [r flicks];
        cell.date               = [rm operationDate:r];
        cell.station            = [rm station:r];
        cell.line               = [rm line:r];
        cell.flickCountComment  = @"";
        if (row == 0) {
            cell.amount = 0;
        } else {
            F2ZRecord *r2 = [history objectAtIndex:row - 1];
            cell.amount = abs([r2 amount] - [r amount]);
        }
    }
    
    return cell;
}

@end
