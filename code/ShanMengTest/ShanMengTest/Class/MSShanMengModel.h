//
//  MSShanMengModel.h
//  ShanMengTest
//
//  Created by Admin on 2019/8/5.
//  Copyright © 2019 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSShanMengURLModel : NSObject

@property (nonatomic, strong) NSString *gif;
@property (nonatomic, strong) NSString *webp;
@property (nonatomic, strong) NSString *w;
@property (nonatomic, strong) NSString *h;

@end

@interface MSShanMengModel : NSObject

@property (nonatomic, strong) MSShanMengURLModel *origin;
@property (nonatomic, strong) MSShanMengURLModel *thumb;
@property (nonatomic, strong) NSString *gifId;
@property (nonatomic, strong) NSNumber *filesize;
@property (nonatomic, strong) NSString *md5;

@end

NS_ASSUME_NONNULL_END
