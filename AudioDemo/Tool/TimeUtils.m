//
//  TimeUtils.m
//  AudioDemo
//
//  Created by apple on 2020/11/6.
//  Copyright © 2020 audio. All rights reserved.
//

#import "TimeUtils.h"

@implementation TimeUtils
+(NSString *) currentDate2DefaultStr
{
    // 实例化NSDateFormatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置日期格式
    [formatter setDateFormat:@"HH:mm:ss.sss"];
    // 获取当前日期
    NSDate *currentDate = [NSDate date];
    NSString *currentDateString = [formatter stringFromDate:currentDate];
    return currentDateString;
}
@end
