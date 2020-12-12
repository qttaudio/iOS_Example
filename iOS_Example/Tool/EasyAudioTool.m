//
//  EasyAudioTool.m
//  AudioDemo
//
//  Created by apple on 2020/11/5.
//  Copyright © 2020 audio. All rights reserved.
//

#import "EasyAudioTool.h"
#import <AVFoundation/AVFoundation.h>

@interface EasyAudioTool ()<AVAudioPlayerDelegate>
{
    //音频播放器
    AVAudioPlayer *audioPlayer;
    //音频地址
    NSString *audioPath;
    //计时器
    NSTimer *timer;
}
@property (nonatomic,copy) ProgressCallBack callBack;
@end

@implementation EasyAudioTool
static id _instance;

+(instancetype)sharedInstance

{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _instance = [[EasyAudioTool alloc] init];
    });
    
    return _instance;
    
}
+(id)allocWithZone:(struct _NSZone*)zone

{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _instance=[super allocWithZone:zone];
    });
    return _instance;
}

-(id)copyWithZone:(NSZone*)zone
{
    return _instance;
}
//NSTimeInterval转换为分钟秒
-(NSString *) getMinuteSecondWithTime:(NSTimeInterval)time
{
    
    int minute = (int)time / 60;
    int second = (int)time % 60;
    
    NSString *minuteStr = minute > 9 ? [NSString stringWithFormat:@"%d",minute] : [NSString stringWithFormat:@"0%d",minute];
    NSString *secondStr = second > 9 ? [NSString stringWithFormat:@"%d",second] : [NSString stringWithFormat:@"0%d",second];

    return [NSString stringWithFormat:@"%@:%@",minuteStr,secondStr];
    
}
//设置音频地址
-(BOOL) setAudioPath:(NSString *)path
{
    NSError *error = nil;
    audioPath = path;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:&error];
    if (error) {
        NSLog(@"AVAudioPlayer error %@",error);
        audioPlayer = nil;
        return NO;
    }
    //设置协议
    audioPlayer.delegate = self;
    //是否循环播放
    audioPlayer.numberOfLoops = 0;
    //加载到缓存中
    [audioPlayer prepareToPlay];
    return YES;
}
//播放
-(BOOL) play
{
    if (!audioPlayer) {
        return NO;
    }
    BOOL isSuccess = [audioPlayer play];
    if (isSuccess) {
        [self startTimer];
    }
   return isSuccess;
}
//暂停
-(void) pause
{
    if (!audioPlayer) {
        return;
    }
    [audioPlayer pause];
    [self stopTimer];
}
//停止
-(void) stop
{
    if (!audioPlayer) {
        return;
    }
    [audioPlayer stop];
    [audioPlayer setCurrentTime:0];
    [self stopTimer];
}
//是否正在播放
-(BOOL) isPlaying
{
    if (!audioPlayer) {
        return NO;
    }
    return [audioPlayer isPlaying];
}

//获取音频播放时长
-(NSTimeInterval) duration
{
    if (!audioPlayer) {
        return 0;
    }
    return [audioPlayer duration];
}

//获取音频播放时长
-(NSString *) durationStr
{
    if (!audioPlayer) {
        return @"00:00";
    }
    return [self getMinuteSecondWithTime:[audioPlayer duration]];
}

//获取当前播放时间（字符串）
-(NSString *) currentTimeStr
{
    if (!audioPlayer) {
        return @"";
    }
    return [self getMinuteSecondWithTime:[audioPlayer currentTime]];
}
//获取当前播放时间
-(NSTimeInterval) currentTime
{
    if (!audioPlayer) {
        return 0;
    }
    return [audioPlayer currentTime];
}

//设置当前播放时间
-(void) setCurrentTime:(NSTimeInterval)time
{
    if (!audioPlayer) {
        return;
    }
    [audioPlayer setCurrentTime:time];
}

//设置进度回调监听
-(void) setProgressCallBack:(ProgressCallBack)callBack
{
    _callBack = callBack;
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

//更新进度及回调
-(void) updateProgress:(NSTimer *)timer
{
    if (self.callBack && audioPlayer) {
        self.callBack(self,[audioPlayer currentTime]);
    }
}

//释放播放器
-(void) releasePlayer
{
    if (audioPlayer) {
        audioPlayer = nil;
    }
    if (self.callBack) {
        self.callBack = nil;
    }
    [self stopTimer];
}
@end
