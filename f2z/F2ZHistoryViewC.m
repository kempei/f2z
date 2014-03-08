//
//  F2ZHistoryViewController.m
//  f2z
//
//  Created by Kempei Igarashi on 2014/02/23.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "F2ZHistoryViewC.h"
#import "F2ZHistoryRecordCell.h"
#import "F2ZRecord.h"
#import "F2ZFelicaReader.h"
#import "F2ZDBManager.h"
#import "FMDatabase.h"
#import "F2ZCategory.h"
#import "F2ZRecordManager.h"

@interface F2ZHistoryViewC ()
- (IBAction)popHistoryViewController:(UIStoryboardSegue *)segue;
@end

static F2ZRecordManager *rm;

@implementation F2ZHistoryViewC
{
    //NSUserDefaults *defaults;
    NSMutableArray *history;
    
    F2ZHistoryRecordCell *pushCell;
}

+(void)initialize
{
    rm = [[F2ZRecordManager alloc] init];
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

    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCell:)];
    [self.tableView addGestureRecognizer:tapGesture];

    UILongPressGestureRecognizer *longPressGesture =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressCell:)];
    longPressGesture.minimumPressDuration = 0.3f;
    [self.tableView addGestureRecognizer:longPressGesture];
}

- (void) didLongPressCell:(UILongPressGestureRecognizer*)longPressRecognizer
{
    if ([longPressRecognizer state] == UIGestureRecognizerStateBegan) {
        // 長押しした場合にはカテゴリに飛ぶ
        CGPoint loc = [longPressRecognizer locationInView:self.tableView];
        NSIndexPath *path = [self.tableView indexPathForRowAtPoint:loc];
        pushCell = (F2ZHistoryRecordCell*)[self.tableView cellForRowAtIndexPath:path];
        [pushCell changeBackGround:F2ZRecordCellCategoryColor];
        [self performSegueWithIdentifier:@"category" sender:self];
    }
}

- (void) didTapCell:(UITapGestureRecognizer*)tapRecognizer
{
    if ([tapRecognizer state] == UIGestureRecognizerStateEnded) {
        CGPoint loc = [tapRecognizer locationInView:self.tableView];
        NSIndexPath *path = [self.tableView indexPathForRowAtPoint:loc];
        pushCell = (F2ZHistoryRecordCell*)[self.tableView cellForRowAtIndexPath:path];
        loc = [tapRecognizer locationInView:pushCell];
        CALayer *layer = pushCell.flickBar.layer.sublayers[1];
        if (CGRectContainsPoint(layer.frame, loc)) {
            // FrameBarの中をタップした場合はカテゴリに飛ぶ
            [pushCell changeBackGround:F2ZRecordCellCategoryColor];
            [self performSegueWithIdentifier:@"category" sender:self];
        } else {
            // FrameBarの外をタップした場合は詳細に飛ぶ
            [pushCell changeBackGround:F2ZRecordCellSelectColor];
            [self performSegueWithIdentifier:@"detail" sender:self];
        }
    }
}

- (void) didSwipeCell:(UISwipeGestureRecognizer*)swipeRecognizer
{
    CGPoint loc = [swipeRecognizer locationInView:self.tableView];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:loc];
    F2ZHistoryRecordCell *cell = (F2ZHistoryRecordCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    NSUInteger row = history.count - indexPath.row;
    F2ZRecord *r = [history objectAtIndex:row];
   
    if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        if (r.flicks < MAX_CATEGORIES) {
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
    [rm storeToDatabase:r];
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
    static NSString *historyIdentifier = @"record";
    static NSString *headerIdentifier = @"header";
    
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:headerIdentifier forIndexPath:indexPath];
        UILabel *amountLabel = (UILabel*)[cell viewWithTag:1]; // storyboard
        [amountLabel setText:[[F2ZHistoryRecordCell formatter] stringFromNumber:[[NSNumber alloc] initWithInteger:[[history lastObject] amount]]]]; // 残額
        return cell;
    } else {
        F2ZHistoryRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:historyIdentifier forIndexPath:indexPath];
        NSInteger row = history.count - indexPath.row;
        F2ZRecord *r = [history objectAtIndex:row];
        if (r.usage == 0 && row > 0) {
            LogDebug(@"adjust usage row=%d", row);
            F2ZRecord *r2 = [history objectAtIndex:row - 1];
            // SCNが2以内の差でなければ引き算しない。カードが違ったり、20件以上の差がある時とみなす。
            if ([r scn] > [r2 scn] && (([r scn] - [r2 scn]) < 3)) {
                r.usage = abs([r2 amount] - [r amount]);
                [rm storeToDatabase:r];
            }
        }
        cell.record = r;
        return cell;
    }
}
// セルの高さを可変にする
-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row == 0) {
        return 27;
    } else {
        return 79;
    }
}
- (void) viewWillAppear:(BOOL)animated
{
    [pushCell changeBackGround:F2ZRecordCellCancelColor]; //別の場所から到達してきた場合
}

- (IBAction)popHistoryViewController:(UIStoryboardSegue *)segue {
    [pushCell changeBackGround:F2ZRecordCellCancelColor];
}

@end
