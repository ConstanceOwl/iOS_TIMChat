//
//  TIMCallViewController.m
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TIMCallViewController.h"




@interface TIMCallViewController ()<UIViewControllerTransitioningDelegate>
// 波浪图层
@property(nonatomic, strong) CAShapeLayer *layer;
// 波浪图层
@property(nonatomic, strong) CAShapeLayer *layer1;
// 波浪图层
@property(nonatomic, strong) CAShapeLayer *layer2;

@property (nonatomic, assign) CGFloat lastFloatBeauty;

@end

@implementation TIMCallViewController

#define kCallTimeOut 30


- (void)dealloc
{
    _callMsgHandler = nil;
    _callReceiver = nil;
}

- (instancetype)initWith:(id<AVRoomAble>)info user:(id<IMHostAble>)user
{
    if (self = [super initWith:info user:user])
    {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}


- (instancetype)initWithReceiver:(IMAUser *)user type:(BOOL)isVoice sponsor:(BOOL)isSponsor
{
    if (self = [self init])
    {
        _callReceiver = user;
        _isCallSponsor = isSponsor;
        _isVoice = isVoice;
    }
    return self;
}

- (instancetype)initWithCommingCall:(IMAUser *)user type:(BOOL)isVoice
{
    if (self = [self init])
    {
        _callReceiver = user;
        _isCallSponsor = NO;
        _isVoice = isVoice;
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)createRoomEngine
{
    if (!_roomEngine)
    {
        id<AVMultiUserAble> ah = (id<AVMultiUserAble>)_currentUser;
        [ah setAvMultiUserState:_isHost ? AVMultiUser_Host : AVMultiUser_Guest];
        [ah setAvCtrlState:[self defaultAVHostConfig]];
        
        _roomEngine = [[TIMChatCallRoomEngine alloc] initWith:(id<IMHostAble, AVMultiUserAble>)_currentUser enableChat:_enableIM];
        _roomEngine.delegate = self;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addWaveAnimation];
    
    [self startCallTimer];
    
    if (!_isCallSponsor)
    {
        [self startCallBellPlay];
    }
}

- (void)startCallBellPlay
{
    if (!_callBellPlayer)
    {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"10" withExtension:@"caf"];
        NSError *err = nil;
        _callBellPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
        
        _callBellPlayer.volume = _isCallSponsor ? 0.3 : 0.8;
        _callBellPlayer.numberOfLoops = 4;
        [_callBellPlayer prepareToPlay];
        [_callBellPlayer play];
    }
}

- (void)stopCallBellPlay
{
    [_callBellPlayer stop];
    _callBellPlayer = nil;
}

- (void)startCallTimer
{
    _callTimer = [NSTimer scheduledTimerWithTimeInterval:kCallTimeOut target:self selector:@selector(onCallTimerOut) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_callTimer forMode:NSRunLoopCommonModes];
}

- (void)onCallTimerOut
{
    if (_isCallSponsor)
    {
        __weak TIMCallViewController *ws = self;
        [self tipMessage:@"对方不在线，无人接忙" delay:2 completion:^{
            
            // 呼叫超时，对方无人接听
            [ws onCallBottomViewHangUp:(TIMCallBottomView *)ws.callBottomView];
        }];
    }
    else
    {
        // 接收超时
        [self onCallBottomViewRefuse:(TIMCallBottomView *)self.callBottomView];
    }
    
    [self stopCallTimer];
}

- (void)stopCallTimer
{
    [_callTimer invalidate];
    _callTimer = nil;
    
    [self stopCallBellPlay];
}

- (BOOL)isImmediatelyEnterLive
{
    // 先起者先进
    return _isCallSponsor;
}

- (void)addWaveAnimation
{
    // 设置第一次电话图标的位置
    self.lastDismissPoint = CGPointMake([UIScreen mainScreen].bounds.size.width - 50, [UIScreen mainScreen].bounds.size.height - 90);
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.layer = [CAShapeLayer layer];
    self.layer.fillColor = [UIColor clearColor].CGColor;
    self.layer.strokeColor = [UIColor whiteColor].CGColor;
    self.layer.lineCap = kCALineCapRound;
    
    self.layer1 = [CAShapeLayer layer];
    self.layer1.fillColor = [UIColor clearColor].CGColor;
    self.layer1.strokeColor = [UIColor whiteColor].CGColor;
    self.layer1.lineCap = kCALineCapRound;
    
    self.layer2 = [CAShapeLayer layer];
    self.layer2.fillColor = [UIColor clearColor].CGColor;
    self.layer2.strokeColor = [UIColor whiteColor].CGColor;
    self.layer2.lineCap = kCALineCapRound;
    
    
    CGFloat width = kTIMCallWidth;
    
    CGFloat width1 = 40;
    CGFloat width2 = 70;
    
    CGFloat centerY = 360.0 / kTIMCallScale;
    
    UIBezierPath *shapePath = [[UIBezierPath alloc] init];
    [shapePath moveToPoint:CGPointMake(-width, centerY)];
    
    UIBezierPath *shapePath1 = [[UIBezierPath alloc] init];
    [shapePath1 moveToPoint:CGPointMake(-width - width1, centerY)];
    
    UIBezierPath *shapePath2 = [[UIBezierPath alloc] init];
    [shapePath2 moveToPoint:CGPointMake(-width - width2, centerY)];
    
    
    CGFloat  x = 0;
    for (int i =0 ; i < 6; i++)
    {
        [shapePath addQuadCurveToPoint:CGPointMake(x - kTIMCallWidth / 2.0, centerY) controlPoint:CGPointMake(x - kTIMCallWidth + kTIMCallWidth/4.0, centerY - 8)];
        
        [shapePath addQuadCurveToPoint:CGPointMake(x, centerY) controlPoint:CGPointMake(x - kTIMCallWidth/4.0, centerY + 8)];
        
        [shapePath1 addQuadCurveToPoint:CGPointMake(x - width1 - kTIMCallWidth / 2.0, centerY) controlPoint:CGPointMake(x - width1 - kTIMCallWidth + kTIMCallWidth/4.0, centerY - 14)];
        [shapePath1 addQuadCurveToPoint:CGPointMake(x - width1, centerY) controlPoint:CGPointMake(x - width1 - kTIMCallWidth/4.0, centerY + 14)];
        
        
        [shapePath2 addQuadCurveToPoint:CGPointMake(x - width2 - kTIMCallWidth / 2.0, centerY) controlPoint:CGPointMake(x - width2 - kTIMCallWidth + kTIMCallWidth/4.0, centerY - 20)];
        [shapePath2 addQuadCurveToPoint:CGPointMake(x - width2, centerY) controlPoint:CGPointMake(x - width2 - kTIMCallWidth/4.0, centerY + 20)];
        x += width;
    }
    
    self.layer.path = shapePath.CGPath;
    self.layer1.path = shapePath1.CGPath;
    self.layer2.path = shapePath2.CGPath;
    
    
    [self.view.layer addSublayer:self.layer];
    [self.view.layer addSublayer:self.layer1];
    [self.view.layer addSublayer:self.layer2];
}

- (void)removeWaveAnimation
{
    [self stopLayerAnimation];
    [self.layer removeFromSuperlayer];
    self.layer = nil;
    
    [self.layer1 removeFromSuperlayer];
    self.layer1 = nil;
    
    [self.layer2 removeFromSuperlayer];
    self.layer2 = nil;
}

- (void)addLiveView
{
    // 子类重写
    //    TCAVLiveBaseViewController *uivc = [[TCAVLiveBaseViewController alloc] initWith:self];
    //    [self addChild:uivc inRect:self.view.bounds];
    //
    //    _liveView = uivc;
}

- (void)addOwnViews
{
    [super addOwnViews];
    
    _callBackground = [[UIImageView alloc] init];
    _callBackground.image = [UIImage imageNamed:@"call_back@2x.jpg"];
    [self.view addSubview:_callBackground];
    
    TIMCallTopView *topView = [[TIMCallTopView alloc] initWith:_callReceiver];
    [self.view addSubview:topView];
    
    self.callTopView = topView;
    self.imgIconView = topView.userIcon;
    
    
    TIMCallBottomView *bottomView = [[TIMCallBottomView alloc] initWith:_callReceiver];
    if (_isCallSponsor)
    {
        [bottomView changeToConnected];
        bottomView.inviteButton.hidden = ![self isCallChatGroup];
    }
    
    bottomView.delegate = self;
    [self.view addSubview:bottomView];
    self.callBottomView = bottomView;
    
    
    _callBackground.frame = self.view.bounds;
    
    CGFloat topHeight = 280.0 / kTIMCallScale;
    CGFloat bottomHeight = 160.0 / kTIMCallScale;
    [self.callTopView setFrameAndLayout:CGRectMake(0, 0, self.view.bounds.size.width, topHeight)];
    [self.callBottomView setFrameAndLayout:CGRectMake(0, self.view.bounds.size.height - bottomHeight, self.view.bounds.size.width, bottomHeight)];
    
    
    _multiView = [[TCShowMultiView alloc] init];
    _multiView.delegate = self;
    [self.view addSubview:_multiView];
    
    [_multiView sizeWith:CGSizeMake(80, kDefaultMargin)];
    [_multiView alignParentTopWithMargin:40];
    [_multiView alignParentRightWithMargin:kDefaultMargin];
    [_multiView relayoutFrameOfSubViews];
    
}

//- (void)layoutOnIPhone
//{
//    [super layoutOnIPhone];
//
//}

#pragma mark - Event

- (UIImage *)callReceiverIcon
{
    return self.imgIconView.image;
}


- (void)starLayerAnimation
{
    CABasicAnimation *animation1 = [CABasicAnimation animation];
    animation1.duration = 1.0;
    animation1.repeatCount = INFINITY;
    animation1.keyPath = @"transform";
    animation1.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(kTIMCallWidth, 0, 0)];
    
    [self.layer addAnimation:animation1 forKey:nil];
    [self.layer1 addAnimation:animation1 forKey:nil];
    [self.layer2 addAnimation:animation1 forKey:nil];
}

- (void)stopLayerAnimation
{
    [self.layer removeAllAnimations];
    [self.layer1 removeAllAnimations];
    [self.layer2 removeAllAnimations];
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [TIMCallTransition transitionWithQSTransitionType:TIMTransitionTypeDismiss presentType:self.pressentType];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [TIMCallTransition transitionWithQSTransitionType:TIMTransitionTypePresent presentType:self.pressentType];
}

- (BOOL)isCallChatGroup
{
    return _callReceiver.isC2CType || [[self callGroupType] isEqualToString:@"Private"];
}

- (NSString *)callGroupType
{
    if (_callReceiver.isC2CType)
    {
        return nil;
    }
    else
    {
        IMAGroup *group = (IMAGroup *)_callReceiver;
        return [group groupType];
    }
}

- (AVIMCMD *)callCMD:(NSInteger)command tip:(NSString *)tip
{
    AVIMCMD *cmd = [[AVIMCMD alloc] initWithCall:command avRoomID:[_roomInfo liveAVRoomId] group:[_roomInfo liveIMChatRoomId] groupType:[self callGroupType] type:_isVoice tip:tip];
    return cmd;
}

- (void)onCallBottomViewHangUp:(TIMCallBottomView *)view
{
    [self stopCallTimer];
    
    __weak TIMCallViewController *ws = self;
    AVIMCMD *cmd = [self callCMD:AVIMCMD_Call_Disconnected tip:nil];
    if (cmd)
    {
        [_callMsgHandler sendCallMsg:cmd finish:^(BOOL isFinished) {
            // 暂不处理，业务逻辑界面显示逻辑
            [ws exitLive];
        }];
    }
    else
    {
        DebugLog(@"参数有误");
        [self exitLive];
    }
    
    
}

- (void)dismiss
{
    if (!self.callFloatView)
    {
        self.pressentType = TIMCallTransitionPressentTypeNormal;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.callFloatView removeFromSuperview];
        self.callFloatView = nil;
    }
    
}
- (void)onCallBottomViewAnswer:(TIMCallBottomView *)view
{
    
    __weak TIMCallViewController *ws = self;
    if (!_isCallSponsor)
    {
        // 对方接听
        AVIMCMD *cmd = [self callCMD:AVIMCMD_Call_Connected tip:nil];
        [_callMsgHandler sendCallMsg:cmd finish:^(BOOL succ) {
            // 暂不处理，业务逻辑界面显示逻辑
            if (succ)
            {
                [ws checkAndEnterAVRoom];
            }
            
        }];
    }
    
    
}

- (void)checkAndEnterAVRoom
{
    [self stopCallTimer];
    [super checkAndEnterAVRoom];
}

- (void)onCallBottomViewRefuse:(TIMCallBottomView *)view
{
    if (!_isCallSponsor)
    {
        __weak TIMCallViewController *ws = self;
        // 对方接听
        AVIMCMD *cmd = [self callCMD:AVIMCMD_Call_LineBusy tip:nil];
        [_callMsgHandler sendCallMsg:cmd finish:^(BOOL succ) {
            // 暂不处理，业务逻辑界面显示逻辑
            [ws exitLive];
        }];
    }
    else
    {
        // 呼叫端不存在的逻辑
    }
}

- (void)onCallBottomViewClickMic:(TIMCallBottomView *)view
{
    view.micButton.enabled = NO;
    __weak TCAVLiveRoomEngine *wr = (TCAVLiveRoomEngine *)_roomEngine;
    [wr asyncEnableMic:!view.micButton.selected completion:^(BOOL succ, NSString *tip) {
        view.micButton.enabled = YES;
        view.micButton.selected = [wr isMicEnable];
    }];
}
- (void)onCallBottomViewClickCamera:(TIMCallBottomView *)view
{
    view.cameraButton.enabled = NO;
    __weak TCAVLiveRoomEngine *wr = (TCAVLiveRoomEngine *)_roomEngine;
    __weak TIMCallViewController *ws = self;
    __weak TCAVCallManager *wm = (TCAVCallManager *)_multiManager;
    [wr asyncEnableCamera:!view.cameraButton.selected completion:^(BOOL succ, NSString *tip) {
        view.cameraButton.enabled = YES;
        BOOL isCameraON = [wr isCameraEnable];
        view.cameraButton.selected = isCameraON;
        
        
        [ws configBottomView];
        
        [ws onSendCameraCMD:isCameraON];
        [ws showLivePreview:[wm hasInteractUsers]];
    }];
}

- (void)onSendCameraCMD:(BOOL)cameraOn
{
    if (!cameraOn)
    {
        // 检查本地
        [_multiManager initiativeCancelInviteUser:(id<AVMultiUserAble>)_currentUser];
    }
    else
    {
        [(TCAVCallManager *)_multiManager addRenderAndRequest:@[_currentUser]];
    }
    
    NSInteger cmdindex = cameraOn ? AVIMCMD_Call_EnableCamera : AVIMCMD_Call_DisableCamera;
    AVIMCMD *cmd = [self callCMD:cmdindex tip:nil];
    [_callMsgHandler sendCallMsg:cmd finish:^(BOOL isFinished) {
        // 暂不处理，业务逻辑界面显示逻辑
        DebugLog(@"发送命令［%d］%@", (int)cmdindex, isFinished ? @"成功" : @"失败");
    }];
    
}


- (void)onSendMicCMD:(BOOL)micOn
{
    NSInteger cmdindex = micOn ? AVIMCMD_Call_EnableMic : AVIMCMD_Call_DisableMic;
    AVIMCMD *cmd = [self callCMD:micOn tip:nil];
    [_callMsgHandler sendCallMsg:cmd finish:^(BOOL isFinished) {
        // 暂不处理，业务逻辑界面显示逻辑
        DebugLog(@"发送命令［%d］%@", (int)cmdindex, isFinished ? @"成功" : @"失败");
    }];
    
}

- (void)showLivePreview:(BOOL)cameraOn
{
    _callTopView.hidden = cameraOn;
    _callBackground.hidden = cameraOn;
}


- (void)onCallBottomViewClickBeauty:(TIMCallBottomView *)view
{
    [UIView animateWithDuration:0.3 animations:^{
        _callTopView.hidden = YES;
        _callBottomView.hidden = YES;
    } completion:^(BOOL finished) {
        TIMCallBeautyView *beautyView = [[TIMCallBeautyView alloc] init];
        [self.view addSubview:beautyView];
        
        __weak TIMCallViewController *ws = self;
        __weak TCAVLiveRoomEngine *wr = (TCAVLiveRoomEngine *)_roomEngine;
        beautyView.changeCompletion = ^(CGFloat value){
            [ws onBeautyChanged:value];
        };
        
        beautyView.dismissBlock = ^{
            ws.callTopView.hidden = [wr isCameraEnable];
            ws.callBottomView.hidden = NO;
        };
        
        [beautyView setFrameAndLayout:self.view.bounds];
        
        // 说明只是当前自己
        _lastFloatBeauty = ([wr getBeauty] * 10)/100.0;
        
        
        [beautyView setBeauty:_lastFloatBeauty];
    }];
}

- (void)onCallBottomViewClickSwitchCamera:(TIMCallBottomView *)view
{
    view.cameraButton.enabled = NO;
    view.beautyButton.enabled = NO;
    view.switchCameraButton.enabled = NO;
    
    __weak TCAVLiveRoomEngine *wr = (TCAVLiveRoomEngine *)_roomEngine;
    [wr asyncSwitchCameraWithCompletion:^(BOOL succ, NSString *tip) {
        view.cameraButton.enabled = YES;
        view.beautyButton.enabled = YES;
        view.switchCameraButton.enabled = YES;
    }];
}

- (void)onBeautyChanged:(CGFloat)value
{
    _lastFloatBeauty = value;
    
    NSInteger be = (NSInteger)((value + 0.05) * 10);
    
    TCAVLiveRoomEngine *wr = (TCAVLiveRoomEngine *)_roomEngine;
    [wr setBeauty:be];
}
- (void)onCallBottomViewClickSpeaker:(TIMCallBottomView *)view
{
    view.speakerButton.enabled = NO;
    [(TCAVLiveRoomEngine *)_roomEngine asyncEnableSpeaker:!view.speakerButton.selected completion:^(BOOL succ, NSString *tip) {
        view.speakerButton.enabled = YES;
        view.speakerButton.selected = succ ? !view.speakerButton.selected : view.speakerButton.selected;
    }];
}
- (void)onCallBottomViewClickInvite:(TIMCallBottomView *)view
{
    // 将数据转换成IMAUser
    NSMutableArray *array = [NSMutableArray arrayWithArray:[_userList allValues]];
    
    // 先弹出
    __weak TIMCallViewController *ws = self;
    FriendPickerViewController *vc = [[FriendPickerViewController alloc] initWithCompletion:^(FriendPickerViewController *selfPtr, BOOL isFinished) {
        // 切换conversation，并通知到其他人
        [ws onStartInvite:selfPtr];
    } existedMembers:array right:@"呼叫"];
    NavigationViewController *nav = [[NavigationViewController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
    
}

- (void)onStartInvite:(FriendPickerViewController *)vc
{
    if (vc.selectedFriends.count == 0)
    {
        // 没有先择对应的人
    }
    else
    {
        if (_callReceiver.isC2CType)
        {
            // 重新创建讨论组
            //            if (vc.selectedFriends.count)
            //            {
            // 更新当前的
            
            NSArray *selected = vc.selectedFriends;
            NSArray *exist = vc.existedFriends;
            
            NSMutableString *title = [NSMutableString string];
            for (id<IMUserAble> iu in exist)
            {
                [title appendFormat:@"%@,", [iu imUserName]];
            }
            
            [title appendString:[_currentUser imUserName]];
            
            NSMutableArray *mems = [NSMutableArray arrayWithArray:exist];
            [mems addObjectsFromArray:selected];
            
            __weak TIMCallViewController *ws = self;
            [[IMAPlatform sharedInstance].contactMgr asyncCreateChatGroupWith:title members:mems succ:^(IMAGroup *group) {
                [ws switchMsgHandler:group];
            } fail:^(int code, NSString *msg) {
                [[HUDHelper sharedInstance] tipMessage:@"邀请失败"];
            }];
            
            // 更换讨论组成功后，再发送邀请消息
            //            }
        }
        else
        {
            // 如果当前是
            if ([self isCallChatGroup])
            {
                // 直接发收邀请消息
            }
            
        }
    }
}

- (void)switchMsgHandler:(IMAGroup *)group
{
    _callReceiver = group;
    if ([_callMsgHandler isKindOfClass:[ChatViewController class]])
    {
        ChatViewController *chatVc = (ChatViewController *)_callMsgHandler;
        [chatVc configWithUser:_callReceiver];
    }
    else if([_callMsgHandler isKindOfClass:[IMAConversation class]])
    {
        _callMsgHandler = [[IMAPlatform sharedInstance].conversationMgr chatWith:group];
    }
    
    [_roomInfo setLiveIMChatRoomId:[group imUserId]];
    AVIMCMD *cmd = [self callCMD:AVIMCMD_Call_Invite tip:nil];
    [_callMsgHandler sendCallMsg:cmd finish:nil];
    
    [(TIMCallTopView *)_callTopView configOwnViewsWith:_callReceiver];
}

- (void)onCallBottomViewClickScale:(TIMCallBottomView *)view
{
    [IMAPlatform sharedInstance].callViewController = self;
    self.pressentType = TIMCallTransitionPressentTypeMask;
    [self dismissViewControllerAnimated:YES completion:nil];
}


//==========================================================================
// RoomEngine回调相关

- (void)onExitLiveSucc:(BOOL)succ tipInfo:(NSString *)tip
{
    [(TIMCallTopView *)_callTopView stopConnectedTimer];
    [IMAPlatform sharedInstance].callViewController = nil;
    [super onExitLiveSucc:succ tipInfo:tip];
    [self dismiss];
}

- (void)onAVLiveEnterLiveSucc:(BOOL)succ tipInfo:(NSString *)tip
{
    [super onAVLiveEnterLiveSucc:succ tipInfo:tip];
    // 发送通话邀请说明
    
    if (succ)
    {
        if (_isCallSponsor)
        {
            AVIMCMD *cmd = [self callCMD:AVIMCMD_Call_Dialing tip:nil];
            [_callMsgHandler sendCallMsg:cmd finish:^(BOOL isFinished) {
                // 暂不处理，业务逻辑界面显示逻辑
                
            }];
        }
        else
        {
            TIMCallBottomView *bottom = (TIMCallBottomView *)self.callBottomView;
            [bottom changeToConnected];
            bottom.inviteButton.hidden = ![self isCallChatGroup];
        }
        
        
        _callBackground.hidden = !_isVoice;
        
    }
    
    if (!_isCallSponsor)
    {
        [self removeWaveAnimation];
        [(TIMCallTopView *)_callTopView startConnectedTimer];
    }
    
    
    
    // 修改提示语，开始计时
    [self configBottomView];
    
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine enableCamera:(BOOL)succ tipInfo:(NSString *)tip
{
    [super onAVEngine:engine enableCamera:succ tipInfo:tip];
    
    if (_isCallSponsor && succ)
    {
        [_multiManager registSelfOnRecvInteractRequest];
    }
    
    if (succ)
    {
        [self configBottomView];
    }
    
}


- (void)configBottomView
{
    [(TIMCallBottomView *)_callBottomView configWithEngine:(TCAVLiveRoomEngine *)_roomEngine];
}



//=============================================================================
// 电话事件重写
- (void)onRecvCallButBusyLine:(AVIMCMD *)recvcmd
{
    // 占线事件
    AVIMCMD *cmd = [self callCMD:AVIMCMD_Call_LineBusy tip:nil];
    __weak TIMCallViewController *ws = self;
    [_callMsgHandler sendCallMsg:cmd finish:^(BOOL isFinished) {
        [ws exitLive];
    }];
}

- (void)onRecvBusyLineCall:(AVIMCMD *)cmd
{
    if (_callReceiver.isC2CType)
    {
        if (_isCallSponsor)
        {
            __weak TIMCallViewController *ws = self;
            [self tipMessage:@"无人接听" delay:2 completion:^{
                [ws exitLive];
            }];
        }
    }
    else
    {
        id<IMUserAble> user = cmd.sender;
        [[HUDHelper sharedInstance] tipMessage:[NSString stringWithFormat:@"%@无人接听", [user imUserName]]];
    }
}

- (void)onRecvNoAnswerCall:(AVIMCMD *)cmd
{
    [self stopCallTimer];
    if (_callReceiver.isC2CType)
    {
        __weak TIMCallViewController *ws = self;
        [self tipMessage:@"对方占线" delay:2 completion:^{
            [ws exitLive];
        }];
    }
    else
    {
        id<IMUserAble> user = cmd.sender;
        [[HUDHelper sharedInstance] tipMessage:[NSString stringWithFormat:@"%@正在通话中", [user imUserName]]];
    }
}

// 收到挂断消息
- (void)onRecvDisconnectCall:(AVIMCMD *)cmd
{
    [self stopCallTimer];
    if (_callReceiver.isC2CType)
    {
        __weak TIMCallViewController *ws = self;
        [self tipMessage:@"对方已挂断" delay:2 completion:^{
            [ws exitLive];
        }];
    }
    else
    {
        
        id<IMUserAble> user = cmd.sender;
        if (user)
        {
            [self exitCall:@[user]];
        }
        [[HUDHelper sharedInstance] tipMessage:[NSString stringWithFormat:@"%@已挂断", [user imUserName]]];
        id<AVMultiUserAble> iiu = [_multiManager interactUserOf:user];
        if (iiu)
        {
            [_multiManager forcedCancelInteractUser:iiu];
        }

    }
}

- (void)onRecvInviteCall:(AVIMCMD *)cmd
{
    // 只可能是群消息
    // 已经在界面中
    if (cmd.isChatGroup)
    {
        //
        IMAUser *user = [[IMAPlatform sharedInstance].contactMgr getUserByGroupId:[cmd liveIMChatRoomId]];
        
        if (!user)
        {
            TIMGroupInfo *gi = [[TIMGroupInfo alloc] init];
            gi.group = [cmd liveIMChatRoomId];
            gi.groupName = [cmd liveIMChatRoomId];
            gi.groupType = [cmd callGroupType];
            user = [[IMAGroup alloc] initWithInfo:gi];
        }
        
        _callReceiver = user;
        _callMsgHandler = [[IMAPlatform sharedInstance].conversationMgr queryConversationWith:user];
        
        if (!(_callReceiver || _callMsgHandler))
        {
            [[HUDHelper sharedInstance] tipMessage:@"错误的邀请消息" delay:1 completion:^{
                [self exitLive];
            }];
        }
        else
        {
            [[HUDHelper sharedInstance] tipMessage:@"切换到讨论组聊天模式"];
            [(TIMCallTopView *)_callTopView configOwnViewsWith:_callReceiver];
        }
        
    }
    else
    {
        DebugLog(@"错误的邀请消息");
    }
    
    
}

- (void)onRecvConnectCall:(AVIMCMD *)cmd
{
    
    if (_callReceiver.isC2CType)
    {
        [self stopCallTimer];
        [self removeWaveAnimation];
        
        [(TIMCallTopView *)_callTopView startConnectedTimer];
    }
    else
    {
        id<IMUserAble> user = cmd.sender;
        if (user)
        {
            [self joinCall:@[user]];
        }
        if (_isCallSponsor)
        {
            [self stopCallTimer];
            [self removeWaveAnimation];
            
            [(TIMCallTopView *)_callTopView startConnectedTimer];
        }
    }
}

- (void)onRecvEnableMic:(AVIMCMD *)cmd
{
    // 暂未想到要处理什么
    // do nothing
    
    id<AVMultiUserAble> auser = [_multiManager interactUserOf:cmd.sender];
    NSInteger state = [auser avCtrlState];
    [auser setAvCtrlState:state | EAVCtrlState_Camera];
}
- (void)onRecvDisableMic:(AVIMCMD *)cmd
{
    // 暂未想到要处理什么
    // do nothing
    
    id<AVMultiUserAble> auser = [_multiManager interactUserOf:cmd.sender];
    NSInteger state = [auser avCtrlState];
    [auser setAvCtrlState:state & ~EAVCtrlState_Mic];
}

- (void)onRecvEnableCamera:(AVIMCMD *)cmd
{
    id<IMUserAble> sender = cmd.sender;
    [_multiManager requestViewOf:(id<AVMultiUserAble>)sender];
    
    [self showLivePreview:[_multiManager hasInteractUsers]];
    
    id<AVMultiUserAble> auser = [_multiManager interactUserOf:sender];
    NSInteger state = [auser avCtrlState];
    [auser setAvCtrlState:state | EAVCtrlState_Camera];
    
    
    
    [self configBottomView];
    [self showLivePreview:[_multiManager hasInteractUsers]];
    
}
- (void)onRecvDisableCamera:(AVIMCMD *)cmd
{
    id<IMUserAble> sender = cmd.sender;
    [_multiManager forcedCancelInteractUser:(id<AVMultiUserAble>)sender];
    
    [self showLivePreview:[_multiManager hasInteractUsers]];
    
    id<AVMultiUserAble> auser = [_multiManager interactUserOf:sender];
    NSInteger state = [auser avCtrlState];
    [auser setAvCtrlState:state & ~EAVCtrlState_Camera];
    
    [self configBottomView];
    [self showLivePreview:[_multiManager hasInteractUsers]];
}


//=============================================================

// 外部分配user窗口位置，此处可在界面显示相应的小窗口
- (void)onAVIMMIMManager:(TCAVIMMIManager *)mgr assignWindowResourceTo:(id<AVMultiUserAble>)user isInvite:(BOOL)inviteOrAuto
{
    if (inviteOrAuto)
    {
        [_multiView inviteInteractWith:user];
    }
    else
    {
        [_multiView addWindowFor:user];
    }
    
    TCShowMultiSubView *subView = [_multiView overlayOf:user];
    
    // 后期作互动窗口切换使用
    [user setAvInvisibleInteractView:subView];
    
    // 相对于全屏的位置
    CGRect rect = [subView relativePositionTo:[UIApplication sharedApplication].keyWindow];
    [user setAvInteractArea:rect];
}

- (void)onAVIMMIMManager:(TCAVIMMIManager *)mgr requestViewComplete:(BOOL)succ
{
    // TODO:子类去分去配置
    TCShowMultiView *multiView = _multiView;
    for (id<AVMultiUserAble> user in mgr.multiResource)
    {
        // 因为QAVEndpoint requestViewList请求的时候并不能知道具体哪个的画面不会到，建议此不要用succ作参考
        // 底层无法知道
        [multiView onRequestViewOf:user complete:YES];
    }
}

// 外部回收user窗口资源信息
- (void)onAVIMMIMManager:(TCAVIMMIManager *)mgr recycleWindowResourceOf:(id<AVMultiUserAble>)user
{
    // TODO:子类去分去配置
    [_multiView cancelInteractWith:user];
}

// 外部界面切换到请求画面操作
- (void)onAVIMMIMManagerRequestHostViewFailed:(TCAVIMMIManager *)mgr
{
    // TODO:子类去分去配置
}

//============================================================
- (void)onMultiView:(TCShowMultiView *)render inviteTimeOut:(id<AVMultiUserAble>)user
{
    
    [_multiManager initiativeCancelInviteUser:user];
}

- (void)onMultiView:(TCShowMultiView *)render clickSub:(id<AVMultiUserAble>)user
{
    DebugLog(@"点击 %@ 的窗口", [user imUserId]);
    //    [_liveView.bottomView switchToShowMultiInteract:user isMain:NO];
    
    __weak TCAVMultiLiveViewController *controller = self;
    
    __weak TCShowMultiView *wm = _multiView;
    
    [controller switchToMainInPreview:user completion:^(BOOL succ, NSString *tip) {
        if (succ)
        {
            // 交换TCShowMultiView上的资源信息
            id<AVMultiUserAble> main = [controller.multiManager mainUser];
            [wm replaceViewOf:user with:main];
            
        }
    }];
    
}

- (void)onMultiView:(TCShowMultiView *)render hangUp:(id<AVMultiUserAble>)user
{
    [_multiManager initiativeCancelInviteUser:user];
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine users:(NSArray *)users event:(QAVUpdateEvent)event
{
    NSMutableArray *hasCamera = [NSMutableArray array];
    for (id<AVMultiUserAble> iu in users)
    {
        // 检查是否是互动观众退出了
        switch (event)
        {
            case QAV_EVENT_ID_ENDPOINT_HAS_CAMERA_VIDEO:
            {
                TCAVIMEndpoint *p = [[TCAVIMEndpoint alloc] initWith:(QAVEndpoint *)iu];
                [hasCamera addObject:p];
                [_multiManager enableInteractUser:iu ctrlState:EAVCtrlState_Camera];
                
            }
                
                break;
            case QAV_EVENT_ID_ENDPOINT_NO_CAMERA_VIDEO:
            {
                [_multiManager disableInteractUser:iu ctrlState:EAVCtrlState_Camera];
            }
                break;
            case QAV_EVENT_ID_ENDPOINT_HAS_AUDIO:
            {
                [_multiManager enableInteractUser:iu ctrlState:EAVCtrlState_Mic];
            }
                break;
            case QAV_EVENT_ID_ENDPOINT_NO_AUDIO:
            {
                [_multiManager disableInteractUser:iu ctrlState:EAVCtrlState_Mic];
            }
                break;
            default:
                break;
        }
    }
    
    
    if (hasCamera.count)
    {
        DebugLog(@"%@", hasCamera);
        [self showLivePreview:YES];
        // 改成请求多人的
        [(TCAVCallManager *)_multiManager addRenderAndRequest:hasCamera];
    }
    else
    {
        
    }
}

- (void)exitLive
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startNoBodyInCallRoomTimer) object:nil];
    [super exitLive];
}

- (void)joinCall:(NSArray *)users
{
    if (!_userList)
    {
        _userList = [[NSMutableDictionary alloc] init];
    }
    
    NSString *curID = [_currentUser imUserId];
    for (id<IMUserAble> iu in users)
    {
        if (![[iu imUserId] isEqualToString:curID]) {
            
            IMAUser *user = [[IMAUser alloc] initWithIMUserAble:iu];
            
            
            [_userList setObject:user forKey:[iu imUserId]];
        }
    }
    
    if (_userList.count)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startNoBodyInCallRoomTimer) object:nil];
    }
    DebugLog(@"%@", _userList);
}

- (void)startNoBodyInCallRoomTimer
{
    if (_userList.count == 0)
    {
        [[HUDHelper sharedInstance] tipMessage:@"无人在线" delay:1 completion:^{
            [self exitLive];
        }];
    }
}

- (void)exitCall:(NSArray *)users
{
    for (id<IMUserAble> iu in users)
    {
        [_userList removeObjectForKey:[iu imUserId]];
    }
    
    if (_userList.count == 0)
    {
        // 开始计时
        [self performSelector:@selector(startNoBodyInCallRoomTimer) withObject:nil afterDelay:10];
    }
    DebugLog(@"%@", _userList);
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine users:(NSArray *)users enterRoom:(id<AVRoomAble>)room
{
    [self joinCall:users];
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine users:(NSArray *)users exitRoom:(id<AVRoomAble>)room
{
    
    for (id<AVMultiUserAble> iu in users)
    {
        NSString *iuid = [iu imUserId];
        // 检查是否是互动观众退出了
        id<AVMultiUserAble> iiu = [_multiManager interactUserOf:iu];
        if (iiu)
        {
            NSString *tip = [NSString stringWithFormat:@"互动观众(%@)退出直播", iuid];
            [self tipMessage:tip delay:2 completion:^{
                [_multiManager forcedCancelInteractUser:iiu];
            }];
        }
        
    }
    // 此处，根据具体业务来处理：比如的业务下，支持主播可以退出再进，这样观众可以在线等待就不用退出了
    [self exitCall:users];
}

- (void)onAVEngine:(TCAVBaseRoomEngine *)engine videoFrame:(QAVVideoFrame *)frame
{
    if (self.callFloatView)
    {
        TIMCallView *callView = (TIMCallView *)self.callFloatView;
        [callView.preView render:frame mirrorReverse:[engine isFrontCamera] fullScreen:NO];
    }
    else
    {
        [super onAVEngine:engine videoFrame:frame];
    }
}

- (id<IMUserAble>)mainUser
{
    return _multiManager.mainUser;
}


@end
