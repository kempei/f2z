//
//  F2ZRecord.m
//  f2z
//
//  Created by Kempei Igarashi on 2014/02/23.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import "F2ZRecord.h"

@implementation F2ZRecord
{
    Byte rawdata[16];
    UInt32 flags;
    
    F2ZCategory *category; // nullable
    NSString *customWhere; // nullable
    NSString *customWhy;   // nullable
}

- (id) init
{
    flags = 0;
    return self;
}

- (id) initWithRawdata: (Byte *) data
                offset: (NSUInteger) offset
{
    [self setRawdata:data offset:offset];
    flags = 0;
    return self;
}
- (void) setRawdata: (Byte *)data
             offset: (NSUInteger)offset
{
    memcpy(rawdata, data + offset, 16);
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    LogTrace(@"encode");
    [encoder encodeBytes:rawdata length:16 forKey:@"data"];
    [encoder encodeInteger:_flicks forKey:@"flicks"];
    [encoder encodeInt32:flags forKey:@"flags"];
    [encoder encodeInteger:_usage forKey:@"usage"];
    if (customWhere) {
        [encoder encodeObject:customWhere forKey:@"customWhere"];
    }
    if (customWhy) {
        [encoder encodeObject:customWhy forKey:@"customWhy"];
    }
    if (category) {
        [encoder encodeObject:category forKey:@"category"];
    }
}

-(id)initWithCoder:(NSCoder *)decoder {
    LogTrace(@"decode");
    self = [super init];
    NSUInteger len;
    [self setRawdata:(Byte *)[decoder decodeBytesForKey:@"data" returnedLength:&len] offset:0];
    _flicks = [decoder decodeIntegerForKey:@"flicks"];
    _usage = [decoder decodeIntegerForKey:@"usage"];
    flags = [decoder decodeInt32ForKey:@"flags"];
    customWhere = [decoder decodeObjectForKey:@"customWhere"]; // nullable
    customWhy = [decoder decodeObjectForKey:@"customWhy"];     // nullable
    category = [decoder decodeObjectForKey:@"category"];       // nullable
    return self;
}

- (UInt8) vendorTypeRaw
{
    return rawdata[0];
}

- (UInt8) operationTypeRaw
{
    return rawdata[1];
}

- (UInt8) paymentTypeRaw
{
    return rawdata[2];
}

- (UInt8) entryTypeRaw
{
    return rawdata[3];
}

- (UInt8) year
{
    return rawdata[4] & 0xFE;
}
- (UInt8) month
{
    return ((rawdata[4] & 0x01) << 3) | (rawdata[5] >> 5);
}
- (UInt8) day
{
    return rawdata[5] & 0x1F;
}

- (UInt16) station1Raw
{
    return rawdata[6] * 256 + rawdata[7];
}

- (UInt16) station2Raw
{
    return rawdata[8] * 256 + rawdata[9];
}

- (UInt16) amount
{
    return rawdata[11] * 256 + rawdata[10]; // little endian
}

- (UInt16) scn
{
    return rawdata[13] * 256 + rawdata[14];
}

- (UInt8) area1
{
    return rawdata[15] >> 6;
}

- (UInt8) area2
{
    return (rawdata[15] & 0x30) >> 4;
}

//// from category
//// カスタムがあればそれ。categoryがセットされていれば(静的)それ。なければflicksからのカテゴリを取得
- (void) setWhere:(NSString*)where
{
    customWhere = where;
}
- (void) setWhy:(NSString*)why
{
    customWhy = why;
}
- (NSString*)where
{
    if (customWhere) {
        return customWhere;
    } else if (category){
        return category.where;
    } else {
        return [F2ZCategory category:_flicks+1].where;
    }
}
- (NSString*)why
{
    if (customWhy) {
        return customWhy;
    } else if (category) {
        return category.why;
    } else {
        return [F2ZCategory category:_flicks+1].why;
    }
}
- (NSString*)categoryTitle
{
    if (category) {
        return category.title;
    } else {
        return [F2ZCategory category:_flicks+1].title;
    }
}

////////////////////////////////////
- (NSString *)description {
    return [NSString stringWithFormat:@"[%02x,%02x,%02x,%02x,%02d,%02d,%02d,%04x,%04x,%05d,%05d,%d,%d,%d,%ld]",
            [self vendorTypeRaw],
            [self operationTypeRaw],
            [self paymentTypeRaw],
            [self entryTypeRaw],
            [self year],
            [self month],
            [self day],
            [self station1Raw],
            [self station2Raw],
            [self amount],
            [self scn],
            [self area1],
            [self area2],
            _flicks,
            flags
        ];
}

-(BOOL)isEqual:(id)other{
	if (other == self)
        return YES;
	if (!other || ![other isKindOfClass:[self class]])
        return NO;
    if ([self scn] == [(F2ZRecord*)other scn]
        && [self year] == [(F2ZRecord*)other year]
        && [self month] == [(F2ZRecord*)other month]
        && [self day] == [(F2ZRecord*)other day]) {
        return YES;
    }
	return NO;
}
-(unsigned)hash{
    return [self scn];
}

@end
