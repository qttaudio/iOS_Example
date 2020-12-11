//
//  EasyAudioTool.h
//  AudioDemo
//
//  Created by apple on 2020/11/5.
//  Copyright © 2020 audio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//进度回调
typedef void(^ProgressCallBack)(id audioTool,NSTimeInterval time);

@interface EasyAudioTool : NSObject

/**
 获取单例
 */
+(instancetype) sharedInstance;
//设置音频地址
-(BOOL) setAudioPath:(NSString *)path;
//播放
-(BOOL) play;
//暂停
-(void) pause;
//停止
-(void) stop;
//是否正在播放
-(BOOL) isPlaying;
//获取音频播放时长
-(NSTimeInterval) duration;
//获取音频播放时长
-(NSString *) durationStr;
//获取当前播放时间（字符串）
-(NSString *) currentTimeStr;
//获取当前播放时间
-(NSTimeInterval) currentTime;
//设置当前播放时间
-(void) setCurrentTime:(NSTimeInterval)time;
//设置进度回调监听
-(void) setProgressCallBack:(ProgressCallBack)callBack;
//释放播放器
-(void) releasePlayer;
@end

NS_ASSUME_NONNULL_END
