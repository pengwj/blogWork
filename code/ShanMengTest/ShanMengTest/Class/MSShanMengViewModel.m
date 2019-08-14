//
//  MSShanMengViewModel.m
//  ShanMengTest
//
//  Created by Admin on 2019/8/5.
//  Copyright © 2019 Admin. All rights reserved.
//

#import "MSShanMengViewModel.h"

#import "MSShanMengModel.h"

#import <AFNetworking/AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>

static NSString * const MSShanMengOPENID = @"1482924088";
static NSString * const MSShanMengSECRET = @"54330bef513070bac0acfc74f3791d6c";

/*
 OPENID : 1482924088
 SECRET : 54330bef513070bac0acfc74f3791d6c
 */

@interface MSShanMengViewModel ()

// 闪萌词库
@property (nonatomic, strong) NSArray *shanmengArray;

@end

@implementation MSShanMengViewModel

- (void)getShanMengEmojiWithKeyword:(NSString *)keyword offset:(NSUInteger)offset limit:(NSUInteger)limit block:(CMArrayResultBlock)block
{
    
    if (![self vaildKeyword:keyword block:block]) {
        return;
    }
    
    NSString *timestamp = [self getNowTimeTimestamp];
    
    NSString *sign = [self getMd5_32Bit_String:[NSString stringWithFormat:@"%@#%@#%@",MSShanMengOPENID,MSShanMengSECRET,timestamp] isUppercase:NO];
    
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [mutDic setObject:MSShanMengOPENID forKey:@"openid"];
    [mutDic setObject:timestamp forKey:@"timestamp"];
    [mutDic setObject:sign forKey:@"sign"];
    [mutDic setObject:keyword forKey:@"keyword"];
    [mutDic setObject:@(offset) forKey:@"offset"];
    [mutDic setObject:@(limit) forKey:@"limit"];

    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]init];
    manager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];

    [manager GET:@"http://api.open.weshineapp.com/1.0/search" parameters:mutDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dic = responseObject;
        NSInteger statusCode = [dic[@"meta"][@"status"] integerValue];
        if (statusCode == 200) {
            
            NSArray *dataArray = dic[@"data"];
            [self.dataArray removeAllObjects];
            
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *tempDic in dataArray) {
                MSShanMengModel *model = [MSShanMengModel yy_modelWithDictionary:tempDic];
                [tempArray addObject:model];
            }
            
            [self refreshDataArray:tempArray];
            
            block(self.dataArray,nil);
            
        } else {
         
            block(nil,nil);
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        block(nil,error);

    }];
}

/**
 匹配词库，检查“关键词”是否有效

 @param keyword 关键词
 @param block 回调
 @return 是否有效
 */
- (BOOL)vaildKeyword:(NSString *)keyword block:(CMArrayResultBlock)block
{
    BOOL isbool = [self.shanmengArray containsObject:keyword];
    
    if (isbool) {
        return YES;
    } else {
        
        [self refreshDataArray:@[]];

        block(self.dataArray,nil);
        return NO;
    }
}

- (void)refreshDataArray:(NSArray *)array
{
    [self.dataArray removeAllObjects];
    [self addDataArrayWithArray:array];
}

- (void)addDataArrayWithArray:(NSArray *)array
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.dataArray.count, [array count])];
    [[self mutableArrayValueForKey:@"dataArray"] insertObjects:array atIndexes:indexSet];
}

- (void)removeEmojiKeyWord
{
    [self.dataArray removeAllObjects];
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}

- (NSArray *)shanmengArray
{
    if (!_shanmengArray) {
        _shanmengArray = @[@"哈哈哈",@"哈哈哈1",@"666"];
    }
    return _shanmengArray;
}


-(NSString *)getNowTimeTimestamp{
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    
    return timeString;
    
}

- (NSString *)getMd5_32Bit_String:(NSString *)srcString isUppercase:(BOOL)isUppercase{
    // 参数 srcString 传进来的字符串
    // 参数 isUppercase 是否需要大小写
    const char *cStr = [srcString UTF8String];// 先转为UTF_8编码的字符串
    unsigned char digest[CC_MD5_DIGEST_LENGTH];//设置一个接受字符数组
    CC_MD5( cStr, (int)strlen(cStr), digest );// 把str字符串转换成为32位的16进制数列，存到了result这个空间中
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [result appendFormat:@"%02x", digest[i]];//将16字节的16进制转成32字节的16进制字符串
    }
    //    x表示十六进制，%02X  意思是不足两位将用0补齐，如果多余两位则不影响
    if (isUppercase) {
        return   [result uppercaseString];
    }else{
        return result;
    }
    
}

@end
