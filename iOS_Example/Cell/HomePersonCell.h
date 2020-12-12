//
//  HomePersonCell.h
//  AudioDemo
//
//  Created by apple on 2020/11/5.
//  Copyright © 2020 audio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RippleAnimationView.h"
NS_ASSUME_NONNULL_BEGIN

@interface HomePersonCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet RippleAnimationView *animView;
//头像
@property (weak, nonatomic) IBOutlet UIImageView *iv_head;
//加号图标
@property (weak, nonatomic) IBOutlet UIImageView *iv_addIcon;
//声音图标
@property (weak, nonatomic) IBOutlet UIImageView *iv_volume;
//静麦图标
@property (weak, nonatomic) IBOutlet UIImageView *iv_silence;
//分贝值
@property (weak, nonatomic) IBOutlet UILabel *label_volumeValue;
//名称
@property (weak, nonatomic) IBOutlet UILabel *label_name;
//开启头部动画
-(void) startHeadAnimation;
//停止头部动画
-(void) stopHeadAnimation;
@end

NS_ASSUME_NONNULL_END
