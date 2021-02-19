//
//  PopView.m
//  AudioDemo
//
//  Created by apple on 2020/11/5.
//  Copyright © 2020 audio. All rights reserved.
//

#import "PopView.h"
//#import "EasyAudioTool.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CDZPicker.h"

@interface PopView ()
@property(nonatomic,strong) NSMutableArray *musicArray;
@property(nonatomic,strong) NSMutableDictionary *musicDict;
@property(nonatomic,copy) NSString *selectedMusicName;
@property(nonatomic,copy) NSString *selectedMusicPath;
//计时器
@property(nonatomic,strong) NSTimer *timer;

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
        
        self.musicArray = [NSMutableArray array];
        self.musicDict = [[NSMutableDictionary alloc] init];
        self.selectedMusicName = nil;
        self.selectedMusicPath = nil;
        //设置音频地址
        NSBundle *musicBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"music" ofType:@"bundle"]];
        NSString* musicPath = [musicBundle pathForResource:@"night" ofType:@"mp3"];
        [_musicArray addObject:@"夜的钢琴曲"];
        [_musicDict setValue:musicPath forKey:@"夜的钢琴曲"];
        _selectedMusicName = @"夜的钢琴曲";
        _selectedMusicPath = musicPath;
        [self getItunesMusic];
        
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
    if (!_timer)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    }
    
    return _timer;
}
//停止计时
-(void) stopTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
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
        self.progressView.value = [self.rtcEngine getSoundPosition];
        self.label_startTime.text = [self getMinuteSecondWithTime:self.progressView.value];
    }
}

//进度滑动事件
-(void) sliderProgressChange:(UISlider *)slider
{
    if (slider == self.progressView) {//音频进度
        [self.rtcEngine setSoundPosition:(int)slider.value];
    }else if (slider == self.pv_music){//音乐
        self.label_musicValue.text = [NSString stringWithFormat:@"%.0f",slider.value];
        [self.rtcEngine adjustPlayVolume:slider.value];
    }else if (slider == self.pv_voice){//人声
        self.label_voiceValue.text = [NSString stringWithFormat:@"%.0f",slider.value];
        [self.rtcEngine adjustMicVolume:slider.value];
    }else if (slider == self.pv_tone){//音调
        self.label_toneValue.text = [NSString stringWithFormat:@"%.0f",slider.value];
        [self.rtcEngine setSoundPitch:slider.value];
        
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
        self.progressView.maximumValue = [self.rtcEngine getSoundDuration];
        self.progressView.continuous = NO;
        self.label_endTime.text = [self getMinuteSecondWithTime:self.progressView.maximumValue];
    }
}

- (void)doPlayOrPauseMusic
{
    if (self.playState == READY) {
        self.playState = PLAYING;
        //开始播放
        [self.rtcEngine playSound:self.selectedMusicPath cycle:1 publish:YES];
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
        [self.rtcEngine pauseSound];
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
        [self.rtcEngine resumeSound];
        //
        [self.btn_play setBackgroundImage:[UIImage imageNamed:@"suspend_icon"] forState:UIControlStateNormal];
        [self startTimer];
        //回调状态
        if (self.statusCallBack) {
            self.statusCallBack(YES);
        }
    }
}

//播放或暂停
- (IBAction)playOrPauseMusic:(id)sender
{
    [self doPlayOrPauseMusic];
}

- (void)doStopMusic {
    [self stopAllAction];
    if (self.statusCallBack) {
        self.statusCallBack(NO);
    }
}

//停止播放
- (IBAction)stopMusic:(id)sender
{
    [self doStopMusic];
}

//停止所有动作
-(void) stopAllAction
{
    self.playState = READY;
    [self.rtcEngine stopSound];
    [self.btn_play setBackgroundImage:[UIImage imageNamed:@"play_icon"] forState:UIControlStateNormal];
    self.progressView.value = 0.0f;
    self.label_startTime.text = @"00:00";
    self.label_endTime.text = @"00:00";
    self.progressView.minimumValue = 0;
    self.progressView.maximumValue = 0;
    [self stopTimer];
}

//选择音乐
- (IBAction)selectMusic:(id)sender
{
    [self getItunesMusic];
    [CDZPicker showSinglePickerInView:self withBuilder:nil strings:[self.musicArray copy] confirm:^(NSArray<NSString *> * _Nonnull strings, NSArray<NSNumber *> * _Nonnull indexs) {
            NSLog(@"select:%@, %@", strings.firstObject, [self.musicDict objectForKey:strings.firstObject]);
        self.label_musicName.text = strings.firstObject;
        self.selectedMusicName = strings.firstObject;
        self.selectedMusicPath =  [[self.musicDict objectForKey:self.selectedMusicName] absoluteString];
        [self doStopMusic];
        [self doPlayOrPauseMusic];
        }cancel:^{
            //your code
        }];
}


- (void)getItunesMusic {
    // 创建媒体选择队列
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    // 创建读取条件
    MPMediaPropertyPredicate *albumNamePredicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInt:MPMediaTypeMusic] forProperty:MPMediaItemPropertyMediaType];
    // 给队列添加读取条件
    [query addFilterPredicate:albumNamePredicate];
    // 从队列中获取条件的数组集合
    NSArray *itemsFromGenericQuery = [query items];
    // 遍历解析数据
    for (MPMediaItem *music in itemsFromGenericQuery) {
        [self resolverMediaItem:music];
    }
}

- (void)resolverMediaItem:(MPMediaItem *)music {
    // 歌名
    NSString *name = [music valueForProperty:MPMediaItemPropertyTitle];
    // 歌曲路径
    NSURL *fileURL = [music valueForProperty:MPMediaItemPropertyAssetURL];
    [_musicArray addObject:name];
    [_musicDict setValue:fileURL forKey:name];
}

-(void) dealloc
{
    [self stopTimer];
}
@end
