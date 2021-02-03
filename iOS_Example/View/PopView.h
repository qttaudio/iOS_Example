//
//  PopView.h
//  AudioDemo
//
//  Created by apple on 2020/11/5.
//  Copyright © 2020 audio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QttRtcEngine.h"


//音乐播放状态
typedef NS_OPTIONS(NSUInteger, MusicPlayState) {
    READY       = 0,
    PLAYING     = 1 << 0,
    PAUSE       = 1 << 1,
};

//是否正在播放回调
typedef void(^StatusCallBack)(BOOL isPlaying);

@interface PopView : UIView
@property (assign,nonatomic) MusicPlayState playState;
@property (strong,nonatomic) QttChannelEngine *rtcEngine;

//播放按钮
@property (weak, nonatomic) IBOutlet UIButton *btn_play;
//歌曲名字
@property (weak, nonatomic) IBOutlet UILabel *label_musicName;
//开始时间
@property (weak, nonatomic) IBOutlet UILabel *label_startTime;
//结束时间
@property (weak, nonatomic) IBOutlet UILabel *label_endTime;
//音频播放进度条
@property (weak, nonatomic) IBOutlet UISlider *progressView;
//音乐
@property (weak, nonatomic) IBOutlet UISlider *pv_music;
@property (weak, nonatomic) IBOutlet UILabel *label_musicValue;
//人声
@property (weak, nonatomic) IBOutlet UISlider *pv_voice;
@property (weak, nonatomic) IBOutlet UILabel *label_voiceValue;
//音调
@property (weak, nonatomic) IBOutlet UISlider *pv_tone;
@property (weak, nonatomic) IBOutlet UILabel *label_toneValue;
//是否正在播放回调
@property (nonatomic,copy) StatusCallBack statusCallBack;

@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacing;

//显示
-(void) show;
//隐藏
-(void) dismiss;
//设置时长
-(void) refreshAudioMixingDuration;
//停止所有动作
-(void) stopAllAction;
@end

