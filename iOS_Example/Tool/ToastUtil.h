//
//  ToastUtil.h
//  AudioDemo
//
//  Created by apple on 2020/11/5.
//  Copyright © 2020 audio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToastUtil : NSObject

+ (void)showToast:(NSString *)text;
+ (void)showToast:(NSString *)text inView:(UIView *)parentView;
@end

NS_ASSUME_NONNULL_END
