//
//  HomePersonCell.m
//  AudioDemo
//
//  Created by apple on 2020/11/5.
//  Copyright © 2020 audio. All rights reserved.
//

#import "HomePersonCell.h"
@interface HomePersonCell()

@end

@implementation HomePersonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.animView.animationType = AnimationTypeWithoutBackground;
    self.animView.multiple = 1.3;
}
//开启头部动画
-(void) startHeadAnimation
{
    [self.animView start];
}
//停止头部动画
-(void) stopHeadAnimation
{
    [self.animView stop];
}
@end
