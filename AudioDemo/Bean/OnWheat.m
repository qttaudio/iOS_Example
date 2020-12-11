//
//  OnWheat.m
//  AudioDemo
//
//  Created by apple on 2020/11/5.
//  Copyright © 2020 audio. All rights reserved.
//

#import "OnWheat.h"

@implementation OnWheat

//重置为默认数据
-(void) reSetDefaultData
{
    self.uid = -1;
    self.isMute = NO;
    self.volumeValue = 0;
    self.headName = nil;
    self.status = FREE;
}


//创建默认实例
+(NSMutableArray *) createDefaultInstanceArray:(NSInteger)count
{
    if (count > 0) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i < count; i ++) {
            OnWheat *bean = [[OnWheat alloc] init];
            bean.uid = -1;
            bean.isMute = NO;
            bean.volumeValue = 0;
            bean.headName = nil;
            bean.status = FREE;
            [array addObject:bean];
        }
        return array;
    }
    return nil;
}
//获取默认头像数组
+(NSArray *) getDefaultHeadNameArray
{
    static NSArray *array;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = [NSArray arrayWithObjects:@"mic_head_icon1",
                 @"mic_head_icon2",
                 @"mic_head_icon3",
                 @"mic_head_icon4",
                 @"mic_head_icon5",
                 @"mic_head_icon6",
                 @"mic_head_icon7",
                 @"mic_head_icon8",nil];
    });
    return array;
}

//获取随机头像
+(NSString *) getRandHeadName
{
    NSArray *headArray = [OnWheat getDefaultHeadNameArray];
    NSUInteger randNum = (0 + (arc4random() % ([headArray count] - 1 + 1)));
    return [headArray objectAtIndex:randNum];
}

@end
