//
//  OnWheat.h
//  AudioDemo
//
//  Created by apple on 2020/11/5.
//  Copyright © 2020 audio. All rights reserved.
//

#import <Foundation/Foundation.h>
//座位状态
typedef NS_OPTIONS(NSUInteger, SeatStatus) {
    //空闲
    FREE       = 0,
    //繁忙
    BUSY       = 1 << 0,
};

/**
 上麦信息
 */
@interface OnWheat : NSObject
//用户id
@property (nonatomic,assign) long uid;
//是否静音（BOOL）
@property (nonatomic,assign) BOOL isMute;
//头像
@property (nonatomic,copy) NSString *headName;
//分贝
@property (nonatomic,assign) NSInteger volumeValue;
//状态
@property (nonatomic,assign) SeatStatus status;
//重置为默认数据
-(void) reSetDefaultData;

//创建默认实例
+(NSMutableArray *) createDefaultInstanceArray:(NSInteger)count;
//获取随机头像
+(NSString *) getRandHeadName;
@end

