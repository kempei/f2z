//
//  F2ZFelicaReader.m
//  f2z
//
//  Created by Kempei Igarashi on 2014/02/22.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import "F2ZFelicaReader.h"
#import "F2ZRecord.h"
#import "FMDatabase.h"
#import "F2ZDBManager.h"

#import "felica_card.h"
#import "felica_cc.h"
#import "felica_cc_stub.h"

#import "ics_types.h"
#import "ics_error.h"
#import "ics_hwdev.h"
#import "icsdrv.h"
#import "icslib_chk.h"
#import "icslog.h"

#ifndef DEFAULT_UUID
#define DEFAULT_UUID ""
#endif
#ifndef DEFAULT_TIMEOUT
#define DEFAULT_TIMEOUT 400 /* ms */
#endif
#ifndef DEFAULT_READ_TIMEOUT
#define DEFAULT_READ_TIMEOUT 5000 /* ms */
#endif
#ifndef DEFAULT_SYSTEM_CODE
//#define DEFAULT_SYSTEM_CODE 0xffff
#define DEFAULT_SYSTEM_CODE 0x0003 /* Suica/PASMO/ICOCA/PiTaPa/TOICA */
#endif
#ifndef DEFAULT_POLLING_MAX_RETRY_TIMES
#define DEFAULT_POLLING_MAX_RETRY_TIMES 9
#endif
#ifndef DEFAULT_POLLING_INTERVAL
#define DEFAULT_POLLING_INTERVAL 500 /* ms */
#endif
#ifndef DEFAULT_POLLING_OPTION
#define DEFAULT_POLLING_OPTION 0
#endif
#ifndef DEFAULT_POLLING_TIMESLOT
#define DEFAULT_POLLING_TIMESLOT 0
#endif

/* These functions are defined in another file. */
extern const icsdrv_basic_func_t* g_drv_func;
extern UINT32 (*g_felica_cc_stub_initialize_func)(felica_cc_devf_t* devf, ICS_HW_DEVICE* dev);

/* constant variables */
const char* s_uuid = DEFAULT_UUID;
const UINT32 s_timeout = DEFAULT_TIMEOUT;
const UINT32 s_read_timeout = DEFAULT_READ_TIMEOUT;
const UINT16 s_system_code = DEFAULT_SYSTEM_CODE;
const UINT32 s_polling_max_retry_times = DEFAULT_POLLING_MAX_RETRY_TIMES;
const UINT32 s_polling_interval = DEFAULT_POLLING_INTERVAL;
const UINT8 s_polling_option = DEFAULT_POLLING_OPTION;
const UINT8 s_polling_timeslot = DEFAULT_POLLING_TIMESLOT;

@implementation F2ZFelicaReader
{
    NSUserDefaults *defaults;
    
    BOOL alertIsFinished;
    NSInteger alertButtonIndex;
    
    UINT32 rc;
    ICS_HW_DEVICE dev;
    felica_cc_devf_t devf;
    felica_card_t card;
}
- (void) initialize_nfc
{
    LogDebug(@"start initialization ...");
    LogDebug(@"calling open(%s) ...", s_uuid);
    rc = g_drv_func->open(&dev, s_uuid);
    if (rc != ICS_ERROR_SUCCESS) {
        [NSException raise:@"NFCException"
                    format:@"failure in open():%u", rc];
    }
    @try {
        if (g_drv_func->initialize_device != NULL) {
            LogDebug(@"calling initialize_device() ...");
            rc = g_drv_func->initialize_device(&dev, s_timeout);
            if (rc != ICS_ERROR_SUCCESS) {
                [NSException raise:@"NFCException"
                            format:@"failure in initialize_device():%u", rc];
            }
        }
        LogDebug(@"calling felica_cc_stub_initialize() ...");
        rc = (*g_felica_cc_stub_initialize_func)(&devf, &dev);
        if (rc != ICS_ERROR_SUCCESS) {
            [NSException raise:@"NFCException"
                        format:@"felica_cc_stub_initialize():%u", rc];
        }
        LogDebug(@"calling ping() ...");
        if (g_drv_func->ping != NULL) {
            rc = g_drv_func->ping(&dev, s_timeout);
            if (rc != ICS_ERROR_SUCCESS) {
                [NSException raise:@"NFCException"
                            format:@"failure in ping:%u", rc];
            }
        }
    }@catch (NSException *exception) {
        rc = g_drv_func->close(&dev);
        if (rc != ICS_ERROR_SUCCESS) {
            LogError(@"failure in close():%u", rc);
            /* Note: continue */
        }
        @throw exception;
    }
}

- (void) finalize_nfc
{
    LogDebug(@"start finalization ...");
    
    if (g_drv_func->rf_off != NULL) {
        LogDebug(@"calling rf_off() ...");
        rc = g_drv_func->rf_off(&dev, s_timeout);
        if (rc != ICS_ERROR_SUCCESS) {
            LogInfo(@"failure in rf_off():%u", rc);
            /* Note: continue */
        }
    }
    
    LogDebug(@"calling close() ...");
    rc = g_drv_func->close(&dev);
    if (rc != ICS_ERROR_SUCCESS) {
        LogInfo(@"failure in close():%u", rc);
    }
}

- (void) poll
{
    int nretries;
    felica_card_option_t card_option;

    UINT8 polling_param[4];
    polling_param[0] = (UINT8)((s_system_code >> 8) & 0xff);
    polling_param[1] = (UINT8)((s_system_code >> 0) & 0xff);
    polling_param[2] = s_polling_option;
    polling_param[3] = s_polling_timeslot;
    
    LogDebug(@"start polling ...");
    for (nretries = 0; nretries <= s_polling_max_retry_times; nretries++) {
        LogDebug(@"calling felica_cc_polling() ... [%d/%d]", nretries, s_polling_max_retry_times);
        rc = felica_cc_polling(&devf,
                               polling_param,
                               &card,
                               &card_option,
                               s_timeout);
        if (rc != ICS_ERROR_TIMEOUT) {
            break;
        }
        LogInfo(@"polling timeout. sleep %d ms", s_polling_interval);
        utl_msleep(s_polling_interval);
    }
    if (rc != ICS_ERROR_SUCCESS) {
        [NSException raise:@"FelicaException"
                    format:@"failure in felica_cc_polling():%u", rc];
    }
    
    LogDebug(@"IDm: %02x%02x%02x%02x%02x%02x%02x%02x",
             card.idm[0], card.idm[1], card.idm[2], card.idm[3],
             card.idm[4], card.idm[5], card.idm[6], card.idm[7]);
    LogDebug(@"PMm: %02x%02x%02x%02x%02x%02x%02x%02x",
             card.pmm[0], card.pmm[1], card.pmm[2], card.pmm[3],
             card.pmm[4], card.pmm[5], card.pmm[6], card.pmm[7]);
    LogDebug(@"Option: ");
    for (int i = 0; i < (int)card_option.option_len; i++) {
        LogDebug(@" %02x", card_option.option[i]);
    }
    
    LogDebug(@"checking card info ...");
    NSData *data = [defaults objectForKey:@"card"];
    if(data != nil) {
        felica_card_t *card_saved = (felica_card_t*)[data bytes];
        if(memcmp(&card, card_saved, sizeof(felica_card_t)) == 0) {
            return;
        }
        LogInfo(@"different card is detected.");
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"確認"
                                   message:@"新しいカードが検出されました。新しいカードから読み込みますか？"
                                  delegate:self
                         cancelButtonTitle:@"いいえ"
                         otherButtonTitles:@"はい", nil];
        alertIsFinished = NO;
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES]; //スレッドが違うのでメインに渡す
        while (!alertIsFinished) {
            [[NSRunLoop currentRunLoop]
             runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        }
        if (alertButtonIndex == 0) {
            LogDebug(@"index = 0");
            [NSException raise:@"SafeException"
                        format:@"the new card should be ignored."];
        } else {
            LogDebug(@"index = 1");
            LogDebug(@"erasing card property ...");
            [defaults setObject:nil forKey:@"card property"];
        }
    }
    LogDebug(@"storing card info ...");
    data = [NSData dataWithBytes:&card length:sizeof(felica_card_t)];
    [defaults setObject:data forKey:@"card"];
}

-(void) alertView: (UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    alertButtonIndex = buttonIndex;
    alertIsFinished = YES;
}

-(BOOL) readProperty
{
    UINT8 status_flag1;
    UINT8 status_flag2;
    UINT8 card_property[16];
    const UINT8 read1_block_list[] = {
        0x80, 0x00
    };
    UINT16 service_code_list[1];
    service_code_list[0] = 0x008B; // 属性情報のサービス

    // カード属性1ブロックを読み込む。
    LogDebug(@"start reading property ...");
    rc = felica_cc_read_without_encryption(&devf, &card, 1,
                                           service_code_list, 1,
                                           read1_block_list, card_property,
                                           &status_flag1, &status_flag2,
                                           s_read_timeout);
    if (rc != ICS_ERROR_SUCCESS && status_flag1 != 0) {
        [NSException raise:@"FelicaException"
                    format:@"failure in felica_cc_read_without_encryption()[p]:%u,%u,%u", rc, status_flag1, status_flag2];
    }

    LogDebug(@"checking card property ...");
    NSData *data = [defaults objectForKey:@"card property"];
    if (data != nil) {
        UINT8 *card_property_stored = (UINT8*)[data bytes];
        if (card_property[0xb] == card_property_stored[0xb] && // 0xb, 0xc が残額
            card_property[0xc] == card_property_stored[0xc] &&
            card_property[0xe] == card_property_stored[0xe] && // 0xe, 0xf が取引通番
            card_property[0xf] == card_property_stored[0xf]) {
            
            LogDebug(@"status is not changed. readHistory will be skipped.");
            //return NO;
            return YES; // *********** いつも更新させる場合 for test
        }
    }
    LogDebug(@"storing card property ...");
    data = [NSData dataWithBytes:card_property length:16];
    [defaults setObject:data forKey:@"card property"];
    return YES;
}

- (BOOL) readHistory
{
    UINT8 status_flag1;
    UINT8 status_flag2;
    UINT8 block_data1[10 * 16];
    UINT8 block_data2[10 * 16];
    const UINT8 read8_block_list_1[] = {
        0x80, 0x00, 0x80, 0x01, 0x80, 0x02, 0x80, 0x03,
        0x80, 0x04, 0x80, 0x05, 0x80, 0x06, 0x80, 0x07,
        0x80, 0x08, 0x80, 0x09
    };
    const UINT8 read8_block_list_2[] = {
        0x80, 0x0A, 0x80, 0x0B, 0x80, 0x0C, 0x80, 0x0D,
        0x80, 0x0E, 0x80, 0x0F, 0x80, 0x10, 0x80, 0x11,
        0x80, 0x12, 0x80, 0x13
    };
    UINT16 service_code_list[1];
    service_code_list[0] = 0x090f; // 利用履歴のサービス

    // 利用履歴を読み込む。20ブロック読み込むが、Felicaの仕様で1度に最大15ブロックまでの読み込みのため、2度に分ける。
    LogDebug(@"start reading history (first half) ...");
    rc = felica_cc_read_without_encryption(&devf, &card, 1,
                                           service_code_list, 10,
                                           read8_block_list_1, block_data1, // 最初の10ブロックを読み込み
                                           &status_flag1, &status_flag2,
                                           s_read_timeout);
    if (rc != ICS_ERROR_SUCCESS && status_flag1 != 0) {
        [NSException raise:@"FelicaException"
                    format:@"failure in felica_cc_read_without_encryption()[p]:%u,%u,%u\n", rc, status_flag1, status_flag2];
    }
    LogDebug(@"start reading history (second half) ...");
    rc = felica_cc_read_without_encryption(&devf, &card, 1,
                                           service_code_list, 10,
                                           read8_block_list_2, block_data2, // 後半の10ブロックを読み込み
                                           &status_flag1, &status_flag2,
                                           s_read_timeout);
    if (rc != ICS_ERROR_SUCCESS && status_flag1 != 0) {
        [NSException raise:@"FelicaException"
                    format:@"failure in felica_cc_read_without_encryption()[p]:%u,%u,%u\n", rc, status_flag1, status_flag2];
    }

    // 2つに分かれた領域を一つにまとめる
    NSMutableArray *carddata = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 10; i++) {
        if (block_data1[16*i] != 0) { //未使用だときっとゼロだろう
            F2ZRecord *rec = [[F2ZRecord alloc] initWithRawdata:block_data1 offset:16*i];
            //LogDebug(@"%@", [rec description]);
            [carddata addObject:rec];
        }
    }
    for (int i = 0; i < 10; i++) {
        if (block_data2[16*i] != 0) { //未使用だときっとゼロだろう
            F2ZRecord *rec = [[F2ZRecord alloc] initWithRawdata:block_data2 offset:16*i];
            //LogDebug(@"%@", [rec description]);
            [carddata addObject:rec];
        }
    }
    BOOL isChanged = NO;
    
    FMDatabase *db = [F2ZDBManager db:@"history"];
    for (F2ZRecord *r in carddata) {
        FMResultSet *rs = [db executeQuery:@"select 1 from history where scn=? and day=? and month=? and year=?",
                   [NSNumber numberWithInteger:[r scn]],
                   [NSNumber numberWithUnsignedChar:[r day]],
                   [NSNumber numberWithUnsignedChar:[r month]],
                   [NSNumber numberWithUnsignedChar:[r year]]];
        BOOL exists = [rs next];
        [rs close];
        if (!exists) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:r];
            rc = [db executeUpdate:@"insert into history (scn, year, month, day, data) values (?,?,?,?,?);",
                       [NSNumber numberWithInteger:[r scn]],
                       [NSNumber numberWithUnsignedChar:[r year]],
                       [NSNumber numberWithUnsignedChar:[r month]],
                       [NSNumber numberWithUnsignedChar:[r day]],
                       data
                       ];
            if (rc != 1) {
                [NSException raise:@"DatabaseException"
                            format:@"failure in inserting new record:%@", r];
            }
            isChanged = YES;
        }
    }

    if (!isChanged) {
        LogError(@"history is not changed."); // カードの取引通番をチェックしているので、本来はここには来ないはず
    }
    return isChanged;
}

- (void)pollAndRead:(id)requester selector:(SEL)refreshSelector
{
    LogDebug(@"start pollAndRead");
    
    defaults = [NSUserDefaults standardUserDefaults];

    //LogDebug(@"removing card history ... (for test)");
    //[defaults removeObjectForKey:@"card history"]; //***********************テスト用のため、消す必要あり

    BOOL willRefresh = NO;

    @try {
        [self initialize_nfc];
        [self poll];
        if ([self readProperty]) {
            willRefresh = [self readHistory];
        }
    } @catch (NSException *exception) {
        LogError(@"%@", exception);
    } @finally {
        [self finalize_nfc];
        [requester performSelectorOnMainThread:refreshSelector
                               withObject:[[NSNumber alloc] initWithBool:willRefresh]
                            waitUntilDone:NO];
    }
}

@end
