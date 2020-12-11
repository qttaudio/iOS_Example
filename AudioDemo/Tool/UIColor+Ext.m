//
//  UIColor+Ext.m
//  AudioDemo
//
//  Created by junjie on 2020/11/6.
//  Copyright © 2020 audio. All rights reserved.
//

#import "UIColor+Ext.h"

@implementation UIColor (Ext)
//16进制转UIColor
+(UIColor *) colorWithHex:(NSUInteger)hex
{
    float r, g, b, a;
    a = 1.0f;
    b = hex & 0x0000FF;
    hex = hex >> 8;
    g = hex & 0x0000FF;
    hex = hex >> 8;
    r = hex;
    
    return [UIColor colorWithRed:r/255.0f
                           green:g/255.0f
                            blue:b/255.0f
                           alpha:a];
}

//  颜色转换为背景图片
+(UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  image;
}
@end
