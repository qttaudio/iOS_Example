//
//  HomeVct.m
//  AudioDemo
//
//  Created by apple on 2020/11/5.
//  Copyright © 2020 audio. All rights reserved.
//

#import "HomeVct.h"
#import "HomePersonCell.h"
#import "PopView.h"
#import "CALayer+Additions.h"
#import <AVFoundation/AVFoundation.h>
#import "DataManage.h"
#import "UIColor+Ext.h"
#import "OnWheat.h"
#import "TimeUtils.h"
#import "ToastUtil.h"
#import "QttRtcEngine.h"
#import "ConfigConstans.h"
#import "NSBundle+Helper.h"
#import "SVProgressHUD.h"

//获取设备屏幕的宽
#define screenWidth [UIScreen mainScreen].bounds.size.width
//获取设备屏幕的高
#define screenHeight [UIScreen mainScreen].bounds.size.height

//最大上麦人数
#define maxPersonNum 8
//默认显示的列数
#define defaultColumnsNum 4


@interface HomeVct ()<UICollectionViewDelegate,UICollectionViewDataSource,QttRtcEngineDelegate>
{
    //上麦信息数据
    NSMutableArray *onWheatArray;
    //我的uid
    long myUid;
    //人数
    NSInteger userCount;
    //库
    QttChannelEngine *rtcEngine;
}
//背景音乐弹出窗口
@property (strong, nonatomic) PopView *pop_bgMusic;

//人数
@property (weak, nonatomic) IBOutlet UIButton *btn_person;
//人数宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *personTextWidth;
//房间号
@property (weak, nonatomic) IBOutlet UIButton *btn_home;
//房间号宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *homeTextWidth;
//显示内容
@property (weak, nonatomic) IBOutlet UITextView *txt_content;
//人员显示布局
@property (weak, nonatomic) IBOutlet UICollectionView *cv_content;
//底部按钮布局
@property (weak, nonatomic) IBOutlet UIView *view_bottom;

//上麦
@property (weak, nonatomic) IBOutlet UIButton *btn_broadcaster;
//静麦
@property (weak, nonatomic) IBOutlet UIButton *btn_silence;
//声音
@property (weak, nonatomic) IBOutlet UIButton *btn_voice;
//外放
@property (weak, nonatomic) IBOutlet UIButton *btn_outPutSound;
//耳返
@property (weak, nonatomic) IBOutlet UIButton *btn_earMonitoring;
//背景音乐
@property (weak, nonatomic) IBOutlet UIButton *btn_bgMusic;
//大笑
@property (weak, nonatomic) IBOutlet UIButton *btn_laugh;
//哭声
@property (weak, nonatomic) IBOutlet UIButton *btn_crying;
@end

@implementation HomeVct

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //耳机状态获取的通知
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//     selector:@selector(audioRouteChangeListenerCallback:)
//     name:AVAudioSessionRouteChangeNotification
//     object:[AVAudioSession sharedInstance]];
    //程序被关掉的通知
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(appWillKill:)
     name:@"AppWillKill"
     object:nil];
    //初始化view相关
    [self initView];
    //初始化数据
    [self initData];
}

//初始化view相关
-(void) initView
{
    //注册cell
    [self.cv_content registerNib:[UINib nibWithNibName:@"HomePersonCell" bundle:nil] forCellWithReuseIdentifier:@"HomePersonCell"];
    // 设置流水布局
    [self.cv_content setCollectionViewLayout:[self getFlowLayout]];
    //音效
    [self.btn_laugh setBackgroundImage:[UIColor imageWithColor:[UIColor colorWithHex:0xD1E5F3]] forState:UIControlStateHighlighted];
    [self.btn_crying setBackgroundImage:[UIColor imageWithColor:[UIColor colorWithHex:0xD1E5F3]] forState:UIControlStateHighlighted];
    //外放
    [self setButtonSelected:self.btn_outPutSound withIsSelect:YES withNewTitle:@"关闭外放"];
    //是否非连续布局
    self.txt_content.layoutManager.allowsNonContiguousLayout = NO;
}

//初始化数据
-(void) initData
{
    onWheatArray = [OnWheat createDefaultInstanceArray:maxPersonNum];
    
    //设置房间号
    NSString *roomNum = [DataManage getObjectFromKey:@"roomNum"];
    if (roomNum) {
        [self.btn_home setTitle:roomNum forState:UIControlStateNormal];
        if ([roomNum length] > 4) {
            NSString *surplusRoomNum = [roomNum substringFromIndex:3];
            CGSize size = [surplusRoomNum sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0f]}];
            self.homeTextWidth.constant += size.width;
        }
    }
    
    //判断是否有插入耳机
    if (![self isHeadSetPlugging]) {
        self.btn_earMonitoring.userInteractionEnabled = NO;
        [self.btn_earMonitoring setTitleColor:[UIColor colorWithHex:0xB8CEFA] forState:UIControlStateNormal];
        self.btn_earMonitoring.layer.borderColor = [UIColor colorWithHex:0xB8CEFA].CGColor;
    }
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //解除SDK包名限制
        [NSBundle startChange];
        
        //库初始化
        [QttChannelEngine setAppkey:APPID];
        [QttChannelEngine setDevLicense:@"" userSerial:@""];
        self->rtcEngine = [QttChannelEngine getChannelInstance];
        //设置监听
        [self->rtcEngine setObserver:self];
        //设置为观众
        [self->rtcEngine changeRole:AUDIENCE];
        //静音状态
        [self->rtcEngine mute:0 mute:NO];
        //进入房间
        [self->rtcEngine join:roomNum token:TOKEN zone:0];
        
        
        //恢复包名
       [NSBundle reSetChange];
    });
}

//在txt_content增加内容
-(void) addMessage2Txt:(NSString *)message
{
    
    self.txt_content.text = [NSString stringWithFormat:@"%@\n%@,%@",self.txt_content.text,[TimeUtils currentDate2DefaultStr],message];
    [self.txt_content scrollRangeToVisible:NSMakeRange(self.txt_content.text.length, 1)];
}

/**
 关闭
 */
- (IBAction)closeAction:(id)sender {
    [rtcEngine leave];
    rtcEngine = nil;
    [self.navigationController popViewControllerAnimated:YES];
}
// 设置流水布局
-(UICollectionViewFlowLayout *) getFlowLayout
{
    // 设置流水布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // 定义大小
    NSInteger cellWidth = (screenWidth - 8 * 3 - 32) / defaultColumnsNum;
    layout.itemSize = CGSizeMake(cellWidth, 128);
    // 设置最小行间距
    layout.minimumLineSpacing = 8;
    // 设置垂直间距
    layout.minimumInteritemSpacing = 8;
    // 设置滚动方向（默认垂直滚动）
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    return layout;
}

#pragma mark - 懒加载
-(PopView *) pop_bgMusic
{
    if (!_pop_bgMusic) {
        _pop_bgMusic = [[PopView alloc] initWithFrame:self.view.frame];
        //播放状态回调
        __weak typeof(self) weakSelf = self;
        _pop_bgMusic.statusCallBack = ^(BOOL isPlaying) {
            [weakSelf setButtonSelected:weakSelf.btn_bgMusic withIsSelect:isPlaying withNewTitle:nil];
        };
    }
    _pop_bgMusic.rtcEngine = self->rtcEngine;
    return _pop_bgMusic;
}
#pragma mark - app状态监听
//关掉
-(void) appWillKill:(NSNotification *)notification
{
    if (self->rtcEngine) {
        [self->rtcEngine stopAllEffects];
        [self->rtcEngine stopSound];
        [self->rtcEngine leave];
    }
}
#pragma mark - 耳机状态监听
//判断耳机当前是否插入
- (BOOL)isHeadSetPlugging
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones] ||
            [[desc portType] isEqualToString:AVAudioSessionPortBluetoothHFP] ||
            [[desc portType] isEqualToString:AVAudioSessionPortBluetoothA2DP])
            return YES;
    }
    return NO;
}
/**
 *  监听耳机插入拔出状态的改变
 *  @param notification 通知
 */
- (void)audioRouteChangeListenerCallback:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *interuptionDict = notification.userInfo;
        NSInteger routeChangeReason   = [[interuptionDict
                                          valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
        switch (routeChangeReason) {
            case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
                //插入耳机时
                self.btn_earMonitoring.userInteractionEnabled = YES;
                [self.btn_earMonitoring setTitleColor:[UIColor colorWithHex:0x0091FF] forState:UIControlStateNormal];
                self.btn_earMonitoring.layer.borderColor = [UIColor colorWithHex:0x0091FF].CGColor;
                break;
            case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            case AVAudioSessionRouteChangeReasonOverride:
                //拔出耳机时
                self.btn_earMonitoring.userInteractionEnabled = NO;
                [self.btn_earMonitoring setTitleColor:[UIColor colorWithHex:0xB8CEFA] forState:UIControlStateNormal];
                self.btn_earMonitoring.layer.borderColor = [UIColor colorWithHex:0xB8CEFA].CGColor;
                break;
            case AVAudioSessionRouteChangeReasonCategoryChange:
                // called at start - also when other audio wants to play
                break;
        }
    });
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;   //返回section数
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [onWheatArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //创建item / 从缓存池中拿 Item
    HomePersonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomePersonCell" forIndexPath:indexPath];
    OnWheat *info = [onWheatArray objectAtIndex:indexPath.row];
    //名称
    if (info.status == BUSY) {
        NSString *name = [NSString stringWithFormat:@"%ld%@",info.uid,info.uid == 0 || info.uid == myUid ? @"(我)" : @""];
        cell.label_name.text = name;
    }else{
        cell.label_name.text = @"麦位";
    }

    //是否静麦
    if (info.isMute) {
        cell.iv_silence.hidden = NO;
    }else{
        cell.iv_silence.hidden = YES;
        //设置分贝
        if (info.volumeValue > 30) {
            cell.iv_volume.hidden = NO;
            cell.label_volumeValue.hidden = NO;
            cell.label_volumeValue.text = [NSString stringWithFormat:@"%ld",info.volumeValue];
            [cell startHeadAnimation];
        }else{
            cell.iv_volume.hidden = YES;
            cell.label_volumeValue.hidden = YES;
            [cell stopHeadAnimation];
        }
    }
    //设置头像
    if (info.headName) {
        [cell.iv_head setImage:[UIImage imageNamed:info.headName]];
        cell.iv_addIcon.hidden = YES;
    }else{
        [cell.iv_head setImage:[UIImage imageNamed:@"item_mic_bg"]];
        cell.iv_addIcon.hidden = NO;
    }

    return cell;
}
#pragma mark - QttChannelEngineDelegate

- (void)onJoinSuccess:(NSString*)channelName uid:(NSUInteger)uid role:(QttChannelRole)role muted:(bool)muted isReconnect:(bool)isReconnect {
    [SVProgressHUD dismiss];
    //我进入房间
    myUid = uid;

    
    if(!isReconnect){
        [self addMessage2Txt:[NSString stringWithFormat:@"用户%ld(我)%@",myUid,@"进入房间了."]];
        userCount ++;
        [_btn_person setTitle:[NSString stringWithFormat:@"%ld",(long)userCount] forState:UIControlStateNormal];
    }else{
        [ToastUtil showToast:@"重连成功"];
    }
}


- (void)onOtherJoin:(NSUInteger)uid role:(QttChannelRole)role muted:(bool)muted {

    if(role == TALKER){
        OnWheat *info = [self findFreeSeat];
        info.uid = uid;
        info.headName = [OnWheat getRandHeadName];
        info.status = BUSY;
        info.isMute = muted;
        [_cv_content reloadData];
    }
    userCount ++;
    [_btn_person setTitle:[NSString stringWithFormat:@"%ld",(long)userCount] forState:UIControlStateNormal];
    [self addMessage2Txt:[NSString stringWithFormat:@"用户%u%@",uid,@"进入房间了."]];
}

- (void)onJoinFail:(int)code message:(NSString*)message {
    [ToastUtil showToast:@"加入失败房间失败"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onConnectionBreak {
    [self addMessage2Txt:@"网络打断"];
}

- (void)onConnectionLost {
    [self addMessage2Txt:@"网络失去连接"];
}

- (void)onWarning:(int)warn message:(NSString*)message {

}

- (void)onError:(int)err message:(NSString*)message {
    [ToastUtil showToast:@"出现错误，请重新进入房间"];
    [self->rtcEngine leave];
}
        
- (void)onLeave {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onOtherLeave:(NSUInteger)uid role:(QttChannelRole)role {
    OnWheat *info = [self findTargetSeat:uid];
    [info reSetDefaultData];
    [_cv_content reloadData];
    
    userCount --;
    [_btn_person setTitle:[NSString stringWithFormat:@"%ld",(long)userCount] forState:UIControlStateNormal];
    [self addMessage2Txt:[NSString stringWithFormat:@"用户%u%@",uid,@"退出房间了."]];
}

- (void)onTalking:(NSArray<QttVolumeInfo*> *_Nonnull)volumeInfos userNum:(NSInteger)userNum {
    for (int i = 0; i < userNum; ++i) {
        OnWheat *onWheat = [self findTargetSeat:[volumeInfos objectAtIndex:i].uid];
        onWheat.volumeValue = [volumeInfos objectAtIndex:i].volume;
        [_cv_content reloadData];
    }
}

- (void)onMuteStatusChanged:(NSUInteger)uid muted:(bool) muted {
    if (uid != 0) {
        OnWheat *onWheat = [self findTargetSeat:uid];
        onWheat.isMute = muted;
        [self.cv_content reloadData];
    //    [self addMessage2Txt:[NSString stringWithFormat:@"用户%u%@",user.uid,user.muted?@"静麦了":@"开麦了"]];
    }
}

- (void)onRoleStatusChanged:(NSUInteger)uid role:(QttChannelRole)role {
    if (uid != 0) {
        if (role == TALKER) {//主播
            OnWheat *info = [self findFreeSeat];
            info.uid = uid;
            info.headName = [OnWheat getRandHeadName];
            info.status = BUSY;
            [_cv_content reloadData];
                
            [self addMessage2Txt:[NSString stringWithFormat:@"用户%u%@",uid,@"上麦了."]];
        }else{//听众
            OnWheat *info = [self findTargetSeat:uid];
            [info reSetDefaultData];
            [_cv_content reloadData];
                
            [_btn_person setTitle:[NSString stringWithFormat:@"%ld",(long)userCount] forState:UIControlStateNormal];
            [self addMessage2Txt:[NSString stringWithFormat:@"用户%u%@",uid,@"下麦了."]];
        }
    } else {
        if (role == TALKER) {//主播
            [self addMessage2Txt:[NSString stringWithFormat:@"用户%ld(我)%@",myUid,@"上麦了."]];
        }else{
            [self addMessage2Txt:[NSString stringWithFormat:@"用户%ld(我)%@",myUid,@"下麦了."]];
        }
    }
}

- (void)onNetworkStats:(NSUInteger)uid txQuality:(QttQualityType)txQuality rxQuality:(QttQualityType)rxQuality stat:(QttRtcStat*)stat {
    
}

- (void)onAudioRouteChanged:(int)route {
    if(route==2||route==3){
        //插入耳机时
        self.btn_earMonitoring.userInteractionEnabled = YES;
        [self.btn_earMonitoring setTitleColor:[UIColor colorWithHex:0x0091FF] forState:UIControlStateNormal];
        self.btn_earMonitoring.layer.borderColor = [UIColor colorWithHex:0x0091FF].CGColor;
   }else{
        //拔出耳机时
        self.btn_earMonitoring.userInteractionEnabled = NO;
        [self.btn_earMonitoring setTitleColor:[UIColor colorWithHex:0xB8CEFA] forState:UIControlStateNormal];
        self.btn_earMonitoring.layer.borderColor = [UIColor colorWithHex:0xB8CEFA].CGColor;
   }
}

- (void)onSoundStateChanged:(int)state {
    //本地音乐播放改变
    if (state == SOUND_PLAYER_STATE_PLAYING && self.pop_bgMusic) {
        [self.pop_bgMusic refreshAudioMixingDuration];
    } else if (state == SOUND_PLAYER_STATE_FINISHED && self.pop_bgMusic) {
        [self.pop_bgMusic stopAllAction];
    } else if (state == SOUND_PLAYER_STATE_STOPPED && self.pop_bgMusic) {
        [self.pop_bgMusic stopAllAction];
    }
}
        
- (void)onEffectFinished:(int)effectId {
    
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - 权限
//检查麦克风权限
-(void) checkRecordPermission
{
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {// 未询问用户是否授权
        //第一次询问用户是否进行授权
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
                if (granted) {
                    // 已授权
                    [self broadcasterAction];
                }else {
                    // 未授权
                    [ToastUtil showToast:@"未授权使用麦克风"];
                }
            });
        }];
    }else if(videoAuthStatus == AVAuthorizationStatusRestricted || videoAuthStatus == AVAuthorizationStatusDenied) {// 未授权
        dispatch_async(dispatch_get_main_queue(), ^{
            [ToastUtil showToast:@"未授权使用麦克风"];
        });
    }else{// 已授权
        dispatch_async(dispatch_get_main_queue(), ^{
            [self broadcasterAction];
        });
    }
}
#pragma mark - 点击事件
- (IBAction)onClick:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    switch (tag) {
        case 101://上麦
            [self checkRecordPermission];
            break;
        case 102://静麦
            [self silenceAction];
            break;
        case 103://关闭声音
            [self closeVoiceAction];
            break;
        case 104://外放
            [self outPutSoundAction];
            break;
        case 105://耳返
            [self earMonitoringAction];
            break;
        case 106://背景音乐
        {
            OnWheat *info = [self findTargetSeat:myUid];
            if(info){
                [self.pop_bgMusic show];
            }else{
                [ToastUtil showToast:@"请先上麦"];
            }
        }
            break;
        case 107://大笑
            [self laughAction];
            break;
        case 108://哭声
            [self cryingAction];
            break;
        default:
            break;
    }

}
//按钮选中和非选中状态
-(void) setButtonSelected:(UIButton *)btn withIsSelect:(BOOL)isSelect withNewTitle:(NSString *)newTitle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [btn setSelected:isSelect];
        if (newTitle) {
            [btn setTitle:newTitle forState:UIControlStateNormal];
        }
        if (isSelect) {
            [btn setBackgroundColor:[UIColor colorWithHex:0x0091FF]];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            [btn setBackgroundColor:[UIColor whiteColor]];
            [btn setTitleColor:[UIColor colorWithHex:0x0091FF] forState:UIControlStateNormal];
        }

    });
}
//找到空闲的位置
-(OnWheat *) findFreeSeat
{
    for(int i = 0 ; i < onWheatArray.count ; i ++){
        OnWheat *info = [onWheatArray objectAtIndex:i];
        if (info.status == FREE) {
            return info;
        }
    }
    return nil;
}
//找到目标的位置
-(OnWheat *) findTargetSeat:(long)uid
{
    long realUid = uid == 0 ? myUid : uid;
    for (OnWheat *info in onWheatArray) {
        if (info.uid == realUid ) {
            return info;
        }
    }
    return nil;
}
//上麦事件
-(void) broadcasterAction
{
    BOOL mark = !self.btn_broadcaster.isSelected;
    BOOL successChange = NO;
    if (mark) {//上麦
        OnWheat *info = [self findFreeSeat];
        if (info) {

            info.uid = myUid;
            info.status = BUSY;
            info.headName = [OnWheat getRandHeadName];
            [self.cv_content reloadData];
            
            successChange = YES;
        }else{
            [ToastUtil showToast:@"人数已满，无法上麦"];
        }
    }else{//下麦
        OnWheat *info = [self findTargetSeat:myUid];
        if (info) {
            [info reSetDefaultData];
            [self.cv_content reloadData];
            [self setButtonSelected:self.btn_silence withIsSelect:NO withNewTitle:@"静麦"];
            successChange = YES;
        }
        [self setButtonSelected:self.btn_bgMusic withIsSelect:NO withNewTitle:nil];
        //停止音效
        [rtcEngine stopAllEffects];
        //停止音乐
        [rtcEngine stopSound];
        if (self.pop_bgMusic) {
            [self.pop_bgMusic stopAllAction];
        }
    }
    if (successChange) {
        //设置为主播/观众
        [rtcEngine changeRole:mark ? TALKER : AUDIENCE];
        [self setButtonSelected:self.btn_broadcaster withIsSelect:mark withNewTitle:mark?@"下麦":@"上麦"];
    }
}

//静麦事件
-(void) silenceAction
{
    BOOL mark = !self.btn_silence.isSelected;
    OnWheat *info = [self findTargetSeat:myUid];
    if (info) {
        info.isMute = mark;
        [self.cv_content reloadData];
//        [self addMessage2Txt:[NSString stringWithFormat:@"%ld（我）%@",myUid,mark?@"静麦了":@"开麦了"]];
        [self setButtonSelected:self.btn_silence withIsSelect:mark withNewTitle:mark?@"开麦":@"静麦"];
        [rtcEngine mute:0 mute:mark];
    }else{
        [ToastUtil showToast:@"请先上麦"];
    }
    
}

//声音事件 -》屏蔽所有人的声音
-(void) closeVoiceAction
{
    BOOL mark = !self.btn_voice.isSelected;
    [self setButtonSelected:self.btn_voice withIsSelect:mark withNewTitle:mark?@"开启声音":@"关闭声音"];
    [rtcEngine muteAllRemote:mark];
}

//外放事件
-(void) outPutSoundAction
{
    BOOL mark = !self.btn_outPutSound.isSelected;
    [self setButtonSelected:self.btn_outPutSound withIsSelect:mark withNewTitle:mark?@"关闭外放":@"开启外放"];
    [rtcEngine setSpeakerOn:mark];
}

//耳返事件
-(void) earMonitoringAction
{
    BOOL mark = !self.btn_earMonitoring.isSelected;
    [self setButtonSelected:self.btn_earMonitoring withIsSelect:mark withNewTitle:mark?@"关闭耳返":@"开启耳返"];
    [rtcEngine enableInEarMonitoring:mark];
}

//大笑事件
-(void) laughAction
{
    OnWheat *info = [self findTargetSeat:myUid];
    if(info){
        NSBundle *musicBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"music" ofType:@"bundle"]];
        NSString *musicPath = [musicBundle pathForResource:@"10190" ofType:@"mp3"];
        [rtcEngine stopEffect:10190];
        [rtcEngine playEffect:10190 filePath:musicPath cycle:1 publish:YES];
    }else{
        [ToastUtil showToast:@"请先上麦"];
    }

}

//哭声事件
-(void) cryingAction
{
    OnWheat *info = [self findTargetSeat:myUid];
    if(info){
        NSBundle *musicBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"music" ofType:@"bundle"]];
        NSString *musicPath = [musicBundle pathForResource:@"4789" ofType:@"mp3"];
        [rtcEngine stopEffect:4789];
        [rtcEngine playEffect:4789 filePath:musicPath cycle:1 publish:YES];
    }else{
        [ToastUtil showToast:@"请先上麦"];
    }

}

#pragma mark - 析构
-(void) dealloc
{
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //释放仿pop窗口
    if (_pop_bgMusic) {
        _pop_bgMusic = nil;
    }
}
@end
