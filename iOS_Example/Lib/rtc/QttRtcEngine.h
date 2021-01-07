//
// Created by QttAudio Inc. on 2020/2/27.
// Copyright (c) 2020 CavanSu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QttLogLevel) {
    LOG_LEVEL_OFF     = 0, //不输出日志信息
    LOG_LEVEL_DEBUG   = 1, //输出SDK所有日志信息
    LOG_LEVEL_MESSAGE = 2, //输出FATAL、ERROR、WARNING和MESSAGE级别的日志信息
    LOG_LEVEL_WARNING = 3, //输出FATAL、ERROR和WARNING级别的日志信息
    LOG_LEVEL_ERROR   = 4, //输出FATAL和ERROR级别的日志信息
    LOG_LEVEL_FATAL   = 5 //输出FATAL级别的日志信息
};

typedef NS_ENUM(NSInteger, QttErrorCode) {
    ERR_OK                        = 0, //没有错误
    ERR_FAILURE                   = 1, //没有明确归类的错误
    ERR_PARAM_ERROR               = 2, //API调用了无效的参数
    ERR_START_CAPTURE_DEVICE_FAIL = 3, //启动音频采集设备失败
    ERR_START_PLAYOUT_DEVICE_FAIL = 4, //启动音频播放设备失败
    ERR_AUDIO_ROUTR_FAIL          = 5, //音频路由错误
    ERR_INVALID_APPKEY            = 6  //APPKEY无效
};

typedef NS_ENUM(NSInteger, QttWarnCode) {
    WARN_WRONG_CALL_SEQUENCE      = 1000, //API调用顺序有误
    WARN_DNS_RESOLVE_FAIL         = 1001, //域名解析出错
    WARN_FIND_SERVER_FAIL         = 1002, //查找服务器失败
    WARN_FIND_SERVER_TIMEOUT      = 1003, //查找服务器超时
    WARN_FIND_SERVER_INTERRUPT    = 1004, //查找服务器中断
    WARN_FIND_SERVER_REJECT       = 1005, //查找服务器被拒绝
    WARN_FIND_SERVER_UNAVAILABLE  = 1006, //没有找到可用服务器
    WARN_CONNECT_SERVER_FAIL      = 1007, //连接服务器失败
    WARN_CONNECT_SERVER_TIMEOUT   = 1008, //连接服务器超时
    WARN_CONNECT_SERVER_INTERRUPT = 1009, //连接服务器中断
    WARN_CONNECT_SERVER_REJECT    = 1010, //连接服务器被拒绝
    WARN_PHONE_CALL_INTERRUPT     = 1011  //音频被电话通话中断
};

typedef NS_ENUM(NSInteger, QttChannelRole) {
    TALKER = 0,  //主播，可说可听
    AUDIENCE = 1 //听众，只能听不能说
};

typedef NS_ENUM(NSInteger, QttChannelScene) {
    CHANNEL_MAIN_TALK = 0, //通话场景
    CHANNEL_MAIN_LIVE = 1  //直播场景
};

typedef NS_ENUM(NSInteger, QttSoundPlayerStateType) {
    SOUND_PLAYER_STATE_PLAYING  = 0, //正常播放
    SOUND_PLAYER_STATE_PAUSED   = 1, //暂停播放
    SOUND_PLAYER_STATE_STOPPED  = 2, //停止播放
    SOUND_PLAYER_STATE_FAILED   = 3, //播放失败
    SOUND_PLAYER_STATE_FINISHED = 4  //播放完成
};

typedef NS_ENUM(NSInteger, QttAudioRouteType) {
    AUDIO_ROUTE_HEADSET      = 0, //耳机为语音路由
    AUDIO_ROUTE_EARPIECE     = 1, //听筒为语音路由
    AUDIO_ROUTE_SPEAKERPHONE = 2, //手机的扬声器为语音路由
    AUDIO_ROUTE_BLUETOOTH    = 3  //蓝牙耳机为语音路由
};

typedef NS_ENUM(NSInteger, QttAudioQuality) {
    AUDIO_QUALITY_SPEECH_MONO   = 0,
    AUDIO_QUALITY_SPEECH_STEREO = 1,
    AUDIO_QUALITY_MUSIC_MONO    = 2,
    AUDIO_QUALITY_MUSIC_STEREO  = 3
};

typedef NS_ENUM(NSInteger, QttAudioMode) {
    AUDIO_MODE_CALL  = 0,
    AUDIO_MODE_LIVE  = 1,
    AUDIO_MODE_MIX   = 2,
    AUDIO_MODE_LIVE2 = 3
};

typedef NS_ENUM(NSInteger, QttQualityType) {
    QUALITY_UNKNOWN = 0, //网络质量未知
    QUALITY_VGOOD   = 1, //网络质量好，通话流畅
    QUALITY_GOOD    = 2, //网络质量较好，偶有卡顿
    QUALITY_POOR    = 3, //网络质量差，但不影响沟通
    QUALITY_BAD     = 4, //网络质量比较差，勉强能沟通
    QUALITY_VBAD    = 5  //网络质量非常差，基本不能沟通
};

@interface QttRtcStat : NSObject
    @property (nonatomic, assign) unsigned int mUpLossRate;   //上行丢包率
    @property (nonatomic, assign) unsigned int mDownLossRate; //下行丢包率
    @property (nonatomic, assign) unsigned int mRttAverage;   //平均Rtt
    @property (nonatomic, assign) unsigned int mJitter;       //抖动
@end

@interface QttVolumeInfo : NSObject
    @property (nonatomic, assign) unsigned int uid;
    @property (nonatomic, assign) int vad;
    @property (nonatomic, assign) int volume;
@end

@protocol QttRtcDataDelegate <NSObject>
@optional
    /**
     * 是否打开observerId的数据回调,影响onData
     * @param observerId
     * @return false时,该observerId不会回调onData函数
     */
    - (bool)dataEnabled:(unsigned int)observerId;
    /**
     * 获取到数据
     * @param buf
     * @param len
     * @param observerId
     */
    - (int)onData:(char *)buf len:(int)len observerId:(unsigned int)observerId;
@end;

@protocol QttRtcEngineDelegate <NSObject>
@optional

    /**
    * 自己加入成功，实现加入频道成功的逻辑
    * @param channelName 频道名字
    * @param uid 用户id。如果用户加入频道前没有设置id，这位服务器自动分配的id
    * @param role 加入频道的角色。TALKER表示主播，可说可听；AUDIENCE表示听众，只能听不能说
    * @param muted 加入频道的静音状态。0表示未静音，1表示静音
    * @param isReconnect 是否是断线重连加入
    */
    - (void)onJoinSuccess:(NSString*)channelName uid:(NSUInteger)uid role:(QttChannelRole)role muted:(bool)muted isReconnect:(bool)isReconnect;


    /**
     * 其他用户加入，实现别人进入频道的逻辑
     * @param uid 加入频道的用户id
     * @param role 加入频道的角色。TALKER表示主播，可说可听；AUDIENCE表示听众，只能听不能说
     * @param muted 加入频道的静音状态。0表示未静音，1表示静音
     */
    - (void)onOtherJoin:(NSUInteger)uid role:(QttChannelRole)role muted:(bool)muted;

    /**
     * 自己加入失败，实现加入频道失败的逻辑
     * @param code 失败状态
     * @param message 失败信息
     */
    - (void)onJoinFail:(int)code message:(NSString*)message;

    /**
    * 网络打断
    */
    - (void)onConnectionBreak;

    /**
     * 网络失去连接
     */
    - (void)onConnectionLost;

    /**
    * 运行过程中的警告信息，通常是网络或者音频设备相关的。一般情况下应用可以忽略，SDK会自己尝试恢复。
    * @param warn 警告码
    * @param message 警告描述
    */
    - (void)onWarning:(int)warn message:(NSString*)message;

    /**
     * 运行过程中的错误信息，SDK无法自行恢复。一般情况下应用需要提示用户并进行对应的处理。
     * @param err 错误码
     * @param message 错误描述
     */
    - (void)onError:(int)err message:(NSString*)message;
        
    /**
     * 实现退出频道的逻辑
     */
    - (void)onLeave;

    /**
     * 其他用户离开，实现别人离开频道的逻辑
     * @param uid 离开频道用户的id
     * @param role 离开频道用户的角色
     */
    - (void)onOtherLeave:(NSUInteger)uid role:(QttChannelRole)role;

    /**
     * 用户音量提示
     * @param volumeInfos 用户音量信息集合
     * @param userNum volumeInfos中用户个数
     */
    - (void)onTalking:(NSArray<QttVolumeInfo*> *_Nonnull)volumeInfos userNum:(NSInteger)userNum;

    /**
     * 用户mute状态，实现静音状态改变的逻辑
     * @param uid 用户id。如果为0，表示自己静音状态，否则表示他人静音状态
     * @param muted 0表示未静音，1表示静音
     */
    - (void)onMuteStatusChanged:(NSUInteger)uid muted:(bool) muted;

    /**
     * 用户角色状态，实现角色状态改变的逻辑
     * @param uid 用户id。如果为0，表示自己角色状态，否则表示他人角色状态
     * @param role TALKER表示主播，可说可听；AUDIENCE表示听众，只能听不能说
     */
    - (void)onRoleStatusChanged:(NSUInteger)uid role:(QttChannelRole)role;

    /**
     * 当前通话网络统计回调，通话中每两秒触发一次
     * @param uid 用户ID。表示该ID的用户的网络质量，如果为0，表示本地用户的网络质量
     * @param txQuality 该用户的上行网络质量
     * @param rxQuality 该用户的下行网络质量
     * @param stat 通话相关的统计信息
     */
    - (void)onNetworkStats:(NSUInteger)uid txQuality:(QttQualityType)txQuality rxQuality:(QttQualityType)rxQuality stat:(QttRtcStat*)stat;

    /**
     * 语音路由变更
     * @param route 路由类型，见QttAudioRouteType
     */
    - (void)onAudioRouteChanged:(int)route;

    /**
     * 声音文件播放状态发生改变
     * @param state 播放状态，见QttSoundPlayerStateType
     */
    - (void)onSoundStateChanged:(int)state;
        
    /**
     * 音效文件播放完毕
     * @param effectId 音效Id
     */
    - (void)onEffectFinished:(int)effectId;
@end


/**
 * 将通话抽象为进入频道,同一个频道内的用户可互相语聊
 */
@interface QttChannelEngine : NSObject

    /**
     * 设置日志文件
     * @param logFile log文件绝对路径，必须保证log文件所在目录存在且可写
     * @param maxSize -1为不限制大小, 单位为KB, 默认为512KB
     */
    + (void)setLogFile:(NSString*)logFile maxSize:(int)maxSize;

    /**
     * 设置日志输出等级
     * 日志级别顺序依次为 OFF、FATAL、ERROR、WARNING、MESSAGE 和 DEBUG。可以看到设置的级别之前所有级别的日志信息。
     * @param level 日志级别
     */
    + (void)setLogLevel:(QttLogLevel)level;

    /**
     * 设置App授权信息,getEngineInstance方法前非必须调用
     * @param licenseFile app.license文件路径
     */
    + (void)setAppLicense:(NSString*)licenseFile;

    /**
     * 设置Dev授权信息,getEngineInstance方法前非必须调用
     * @param licenseDir 授权文件存放目录
     * @param userSerial 用户序列号,便于设备标示绑定
     */
    + (void)setDevLicense:(NSString*)licenseDir userSerial:(NSString*)userSerial;

    /**
     * 设置appkey,getChannelInstance方法前调用，必须设置
     * @param appkey appkey字符串
     */
    + (void)setAppkey:(NSString*)appkey;

    /**
     * 初始化获取QttChannelEngine对象指针,单例
     * @return QttChannelEngine对象指针
     */
    + (instancetype)getChannelInstance;

    /**
     * 释放QttChannelEngine实例
     */
    + (void)destroy;

    /**
     * 获取QTT激活序列号
     * @return 返回XXXX-XXXX-XXXX-XXXX或者NULL
     */
    + (NSString*)getQttSerial;

    /**
    * 获取SDK版本号
    * @return SDK版本号
    */
    + (NSString*)getQttVersion;

    /**
     * 如果getChannelInstance返回NULL空指针，调用该接口获取出错信息
     * @return 出错信息
     */
    + (NSString*)getError;

    /**
     * TODO
     */
    - (int)setAudioConfig:(QttAudioQuality)quality mode:(QttAudioMode)mode;
    
    /**
     * 设置频道事件观察者
     * @param observer 观察者对象
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)setObserver:(id<QttRtcEngineDelegate>)observer;
    
    /**
     * 设置用户id
     * @param uid 用户id
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)setUid:(unsigned int)uid;
    
    /**
     * 设置原始音频采集数据监听器，可修改数据，但不能改变数据大小
     * @param observer 数据监听器
     * @param channels 声道数，可以为1或者2
     * @param bufSize 数据回调大小，小于等于0为默认值
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)setRecordDataObserver:(id<QttRtcDataDelegate>)observer observerId:(unsigned int)observerId samplerate:(int)samplerate channels:(int)channels bufSize:(int)bufSize;
    
    /**
     * 设置原始音频播放数据监听器，可修改数据，但不能改变数据大小
     * @param observer 数据监听器
     * @param bufSize 数据回调大小，小于等于0为默认值
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)setPlaybackDataObserver:(id<QttRtcDataDelegate>)observer observerId:(unsigned int)observerId samplerate:(int)samplerate channels:(int)channels bufSize:(int)bufSize;
    
    /**
     * 开启（关闭）音量检测
     * @param intervalMs 检测间隔，毫秒；如果小于等于0，表示关闭音量检测
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)setVolumeDetection:(int)intervalMs;
    
    /**
     * 进入频道，进入成功还是失败的结果在回调通知
     * @param channelId 频道名称
     * @param token 验证token
     * @param zone分区，如果为0，由系统指定最佳服务器；否则由用户指定使用该分区的服务器
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)join:(NSString*)channelId token:(NSString*)token zone:(int)zone;
    
    /**
     * 开启（关闭）扬声器
     * @param on true，开启；false，关闭
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)setSpeakerOn:(bool)on;

    /**
    * 扬声器是否开启
    * @return
    - true: 开启.
    - false: 关闭.
    */
    - (bool)isSpeakerOn;

    /**
     * 改变角色，改变的结果在回调通知
     * @param role TALKER:主播，可说可听; AUDIENCE:听众，只能听不能说
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)changeRole:(QttChannelRole)role;
    
    /**
     * mute频道成员
     * @param uid 用户id,0可以表示为自己
     * @param mute true为静音；false为不静音
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)mute:(unsigned int)uid mute:(bool)mute;
    
    /**
     * mute所有频道其他成员
     * @param mute true为静音；false为不静音
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)muteAllRemote:(bool)mute;
    
    /**
     * 调节频道内uid用户说话的音量
     * @param uid 用户id
     * @param vol [0-400],默认为100，0为无声
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)adjustUserVolume:(unsigned int)uid vol:(int)vol;
    
    /**
     * 调节mic采集音量
     * @param vol [0-400],默认为100，0为无声
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)adjustMicVolume:(int)vol;
    
    /**
     * 调节总的播放音量
     * @param vol [0-400],默认为100，0为无声
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)adjustPlayVolume:(int)vol;
    
    /**
     * 频道内录音
     * @param wavFile 保存的wav文件路径，如果文件路径不存在，会创建
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)startRecord:(NSString*)wavFile;
    
    /**
     * 停止录音
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)stopRecord;
    
    /**
     * 开启/关闭耳返
     * @param enable true启用；false关闭
     */
    - (int)enableInEarMonitoring:(bool)enable;
    
    /**
     * 设置耳返音量
     * @param volume [0-100],默认为100
     */
    - (int)setInEarMonitoringVolume:(int)volume;
    
    /**
     * 离开频道
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)leave;
    
    /*
     * 开始播放声音文件。
     * 成功调用该方法后，后续的播放状态变化通过onSoundStateChanged获取。
     * @param filePath 指定需要播放的声音文件的绝对路径。
     * @param cycle 循环播放次数。正整数表示具体的循环播放的次数，-1表示无限循环播放。
     * @param publish
     - true: 本地用户和远端用户都能听到播放的声音
     - false: 只有本地用户可以听到播放的声音
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)playSound:(NSString*)filePath cycle:(int)cycle publish:(bool)publish;
    
    /*
     * 停止播放声音文件。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)stopSound;
    
    /*
     * 暂停播放声音文件。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)pauseSound;
    
    /*
     * 恢复播放声音文件。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)resumeSound;
    
    /*
     * 设置声音文件的播放位置。
     * @param pos 声音文件的播放位置，单位为毫秒。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)setSoundPosition:(int)pos;
    
    /*
     * 获取声音文件的播放进度，单位为毫秒。
     * @return
     - >= 0: 音乐文件当前播放进度
     - < 0: 失败.
     */
    - (int)getSoundPosition;
    
    /*
     * 获取声音文件总时长，单位为毫秒。
     * @return
     - >= 0: 声音文件时长。
     - < 0: 失败.
     */
    - (int)getSoundDuration;
    
    /*
     * 调整播放的声音文件的音调。
     * @param pitch 按半音音阶调整本地播放的音乐文件的音调，默认值为0，即不调整音调，取值范围为 [-12,12]。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)setSoundPitch:(int)pitch;
    
    /*
     * 调节声音文件播放音量。
     * @param vol 声音文件音量范围为 0~100。100（默认值）为原始文件音量。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)setSoundVolume:(int)vol;
    
    /*
     * 调节声音文件本地播放音量。
     * @param vol 声音文件音量范围为 0~100。100（默认值）为原始文件音量。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)setSoundPlayoutVolume:(int)vol;
    
    /*
     * 调节声音文件远端播放音量。
     * @param vol 声音文件音量范围为 0~100。100（默认值）为原始文件音量。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)setSoundPublishVolume:(int)vol;
    
    /*
     * 获取声音文件的本地播放音量。
     * @return
     - >= 0: 声音文件的本地播放音量，范围为 [0, 100]。
     - < 0: 失败.
     */
    - (int)getSoundPlayoutVolume;
    
    /*
     * 获取声音文件的远端播放音量。
     * @return
     - >= 0: 声音文件的远端播放音量，范围为 [0, 100]。
     - < 0: 失败.
     */
    - (int)getSoundPublishVolume;
    
    /*
     * 开始播放音效文件。
     * 可以多次调用该方法，同时播放多个音效文件，实现音效叠加。
     * 播放音效结束后，会触发onEffectFinished。
     * @param effectId 音效文件ID。
     * @param filePath 指定需要播放的音效文件的绝对路径。
     * @param cycle 循环播放次数。正整数表示具体的循环播放的次数，-1表示无限循环播放。
     * @param publish
     - true: 本地用户和远端用户都能听到播放的声音
     - false: 只有本地用户可以听到播放的声音
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)playEffect:(int)effectId filePath:(NSString*)filePath cycle:(int)cycle publish:(bool)publish;
    
    /*
     * 停止播放音效文件。
     * @param effectId 音效文件ID。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)stopEffect:(int)effectId;
    
    /*
     * 停止播放所有音效文件。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)stopAllEffects;
    /*
     * 暂停播放音效文件。
     * @param effectId 音效文件ID。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)pauseEffect:(int)effectId;
    
    /*
     * 暂停播放所有音效文件。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)pauseAllEffects;
    
    /*
     * 恢复播放音效文件。
     * @param effectId 音效文件ID。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)resumeEffect:(int)effectId;
    
    /*
     * 恢复播放所有音效文件。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)resumeAllEffects;
    
    /*
     * 获取播放音效文件音量。
     * @return
     -  >= 0: 音效文件的播放音量，范围为 [0, 100]。
     - < 0: 失败.
     */
    - (int)getEffectsVolume;
    
    /*
     * 设置音效文件的播放音量。
     * @param vol 音效文件音量范围为 0~100。100（默认值）为原始文件音量。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)setEffectsVolume:(int)volume;
    
    /*
     * 设置指定音效文件的音量。
     * @param effectId 音效文件ID。
     * @param vol 音效文件音量范围为 0~100。100（默认值）为原始文件音量。
     * @return
     - 0(ERR_SUCCESS): 成功.
     - < 0: 失败.
     */
    - (int)setVolumeOfEffect:(int)effectId vol:(int)vol;
@end

NS_ASSUME_NONNULL_END

