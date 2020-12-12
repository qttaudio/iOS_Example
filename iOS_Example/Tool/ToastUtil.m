//
//  ToastUtil.m
//  AudioDemo
//
//  Created by apple on 2020/11/5.
//  Copyright © 2020 audio. All rights reserved.
//

#import "ToastUtil.h"
//获取设备屏幕的宽
#define screenWidth [UIScreen mainScreen].bounds.size.width
//获取设备屏幕的高
#define screenHeight [UIScreen mainScreen].bounds.size.height
@implementation ToastUtil

+ (void)showToast:(NSString *)text{
    [ToastUtil showToast:text inView:[UIApplication sharedApplication].windows.lastObject];
}

+ (void)showToast:(NSString *)text inView:(UIView *)parentView {
    if (!parentView) {
        return;
    }
    CGSize labelSize = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.f]}];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:16.f];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = labelSize.height/4;
    label.layer.masksToBounds = YES;
    label.backgroundColor = [UIColor blackColor];
    label.textColor = [UIColor whiteColor];
    label.frame = CGRectMake((screenWidth / 2 - labelSize.width / 2), (screenHeight - 150), labelSize.width + 10, labelSize.height + 10);
    [parentView addSubview:label];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [label removeFromSuperview];
    });
}
@end
