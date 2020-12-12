//
//  UIColor+Ext.h
//  AudioDemo
//
//  Created by junjie on 2020/11/6.
//  Copyright © 2020 audio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Ext)
//16进制转UIColor
+(UIColor *) colorWithHex:(NSUInteger)hex;
//  颜色转换为背景图片
+(UIImage *)imageWithColor:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END
