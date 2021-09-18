//
//  PopView.m
//  AudioDemo
//
//  Created by apple on 2020/11/5.
//  Copyright © 2020 audio. All rights reserved.
//

#import "PopView.h"
//#import "EasyAudioTool.h"

@interface PopView ()
{
    //计时器
    NSTimer *timer;
}
@end
@implementation PopView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame{
    //从xib中初始化视图
    if (self = [super initWithFrame:frame]) {
        UIView *mView = [[[NSBundle mainBundle] loadNibNamed:@"PopView" owner:self options:nil] lastObject];
        mView.frame = frame;
        [self addSubview:mView];
        //设置背景点击
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        self.bgView.userInteractionEnabled = YES;
        [self.bgView addGestureRecognizer:tapGesture];
        //重置状态
        self.playState = READY;
        //设置音频地址
        NSBundle *musicBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"music" ofType:@"bundle"]];
        self.musicPath = [musicBundle pathForResource:@"night" ofType:@"mp3"];
//        [[EasyAudioTool sharedInstance] setAudioPath:musicPath];
//        //设置时长
//        self.progressView.minimumValue = 0;
//        self.progressView.maximumValue = [[EasyAudioTool sharedInstance] duration];
//        self.progressView.continuous = NO;
//        self.label_endTime.text = [[EasyAudioTool sharedInstance] durationStr];
        //监听滑动事件
        [self.progressView addTarget:self action:@selector(sliderProgressChange:) forControlEvents:UIControlEventValueChanged];
        [self.pv_music addTarget:self action:@selector(sliderProgressChange:) forControlEvents:UIControlEventValueChanged];
        [self.pv_voice addTarget:self action:@selector(sliderProgressChange:) forControlEvents:UIControlEventValueChanged];
        [self.pv_tone addTarget:self action:@selector(sliderProgressChange:) forControlEvents:UIControlEventValueChanged];
        //播放进度增加点击事件
        UITapGestureRecognizer *sliderTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
        [self.progressView addGestureRecognizer:sliderTapGesture];
    }
    return self;
}

- (void)actionTapGesture:(UITapGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:self.progressView];
    CGFloat value = (self.progressView.maximumValue - self.progressView.minimumValue) * (touchPoint.x / self.progressView.frame.size.width );
    [self.progressView setValue:(int)value animated:YES];
}

//开始计时
-(NSTimer *) startTimer
{
    if (!timer)
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    }
    
    return timer;
}
//停止计时
-(void) stopTimer
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

//毫秒转换为分钟秒
-(NSString *) getMinuteSecondWithTime:(NSTimeInterval)time
{
    NSTimeInterval secondTime = time / 1000;
    int minute = (int)secondTime / 60;
    int second = (int)secondTime % 60;
    
    NSString *minuteStr = minute > 9 ? [NSString stringWithFormat:@"%d",minute] : [NSString stringWithFormat:@"0%d",minute];
    NSString *secondStr = second > 9 ? [NSString stringWithFormat:@"%d",second] : [NSString stringWithFormat:@"0%d",second];

    return [NSString stringWithFormat:@"%@:%@",minuteStr,secondStr];
    
}

//更新进度及回调
-(void) updateProgress:(NSTimer *)timer
{
    //非触摸时回调
    if (![self.progressView isTouchInside] && self.progressView.maximumValue > 0) {
        self.progressView.value = [self.rtcEngine getSoundMixingCurrentPosition];
        self.label_startTime.text = [self getMinuteSecondWithTime:self.progressView.value];
    }
}

//进度滑动事件
-(void) sliderProgressChange:(UISlider *)slider
{
    if (slider == self.progressView) {//音频进度
        [self.rtcEngine setSoundMixingPosition:(int)slider.value];
    }else if (slider == self.pv_music){//音乐
        self.label_musicValue.text = [NSString stringWithFormat:@"%.0f",slider.value];
        [self.rtcEngine adjustPlaybackVolume:slider.value];
    }else if (slider == self.pv_voice){//人声
        self.label_voiceValue.text = [NSString stringWithFormat:@"%.0f",slider.value];
        [self.rtcEngine adjustRecordingVolume:slider.value];
    }else if (slider == self.pv_tone){//音调
        self.label_toneValue.text = [NSString stringWithFormat:@"%.0f",slider.value];
        [self.rtcEngine setSoundMixingPitch:slider.value];
        
    }
    
}


//显示
-(void) show
{
    UIWindow *windows = [UIApplication sharedApplication].keyWindow;
    [windows addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform tf = CGAffineTransformMakeTranslation(0, -self.bottomView.frame.size.height);
        [self.bottomView setTransform:tf];
        if (self.playState == PLAYING) {
            [self startTimer];
        }
    }];

}
//隐藏
-(void) dismiss
{
    if (![self superview]) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomView.transform =  CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self stopTimer];
    }];
}

//关闭
- (IBAction)closeAction:(id)sender
{
    [self dismiss];
}

//设置时长
-(void) refreshAudioMixingDuration
{
    if (self.progressView.maximumValue <= 1) {
        //设置时长
        self.progressView.minimumValue = 0;
        self.progressView.maximumValue = [self.rtcEngine getSoundMixingDuration];
        self.progressView.continuous = NO;
        self.label_endTime.text = [self getMinuteSecondWithTime:self.progressView.maximumValue];
    }
}

//播放或暂停
- (IBAction)playOrPauseMusic:(id)sender
{
    if (self.playState == READY) {
        self.playState = PLAYING;
        //开始播放
        [self.rtcEngine startSoundMixing:self.musicPath cycle:1 publish:YES];
        //
        [self.btn_play setBackgroundImage:[UIImage imageNamed:@"suspend_icon"] forState:UIControlStateNormal];
        [self startTimer];
        //回调状态
        if (self.statusCallBack) {
            self.statusCallBack(YES);
        }
        
    }else if(self.playState == PLAYING){
        self.playState = PAUSE;
        //暂停播放
        [self.rtcEngine pauseSoundMixing];
        //
        [self.btn_play setBackgroundImage:[UIImage imageNamed:@"play_icon"] forState:UIControlStateNormal];
        [self stopTimer];
        //回调状态
        if (self.statusCallBack) {
            self.statusCallBack(NO);
        }
    }else if(self.playState == PAUSE){
        self.playState = PLAYING;
        //重新播放
        [self.rtcEngine resumeSoundMixing];
        //
        [self.btn_play setBackgroundImage:[UIImage imageNamed:@"suspend_icon"] forState:UIControlStateNormal];
        [self startTimer];
        //回调状态
        if (self.statusCallBack) {
            self.statusCallBack(YES);
        }
    }
    
}
//停止播放
- (IBAction)stopMusic:(id)sender
{
    [self stopAllAction];
    if (self.statusCallBack) {
        self.statusCallBack(NO);
    }
}

//停止所有动作
-(void) stopAllAction
{
    self.playState = READY;
    [self.rtcEngine stopSoundMixing];
    [self.btn_play setBackgroundImage:[UIImage imageNamed:@"play_icon"] forState:UIControlStateNormal];
    self.progressView.value = 0.0f;
    self.label_startTime.text = @"00:00";
    [self stopTimer];
}

-(void) dealloc
{
    [self stopTimer];
}
@end
