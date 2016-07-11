//
//  TIMCallTopView.m
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TIMCallTopView.h"

@implementation TIMCallTopView

- (instancetype)initWith:(IMAUser *)user
{
    if (self = [super initWithFrame:CGRectZero])
    {
        _callReceiver = user;
        [self addOwnViews];
        [self configOwnViews];
    }
    return self;
}

- (void)startConnectedTimer
{
    if (_connectedTimer == nil)
    {
        _connectedTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onConnectTimeRefresh) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_connectedTimer forMode:NSRunLoopCommonModes];
        
        _connectedTime = 0;
        [self refreshCallTip];
    }
}

- (void)onConnectTimeRefresh
{
    _connectedTime++;
    [self refreshCallTip];
    
}

- (void)refreshCallTip
{
    NSString *durStr = nil;
    if (_connectedTime > 3600)
    {
        int h = (int)_connectedTime/3600;
        int m = (int)(_connectedTime - h *3600)/60;
        int s = (int)_connectedTime%60;
        durStr = [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
    }
    else
    {
        int m = (int)_connectedTime/60;
        int s = (int)_connectedTime%60;
        durStr = [NSString stringWithFormat:@"%02d:%02d", m, s];
    }
    
    
    _callTip.text = durStr;

}

- (void)stopConnectedTimer
{
    [_connectedTimer invalidate];
    _connectedTimer = nil;
}

- (UIImage *)callReceiverIcon
{
    if ([_callReceiver isC2CType])
    {
        return kDefaultUserIcon;
        
    }
    else if ([_callReceiver isGroupType])
    {
        return kDefaultGroupIcon;
    }
    return nil;
}

- (NSString *)callReceiverName
{
    return [_callReceiver showTitle];
}

- (NSString *)callReceiverDesc
{
    if ([_callReceiver isC2CType])
    {
        return [NSString stringWithFormat:@"正在呼叫%@", [_callReceiver showTitle]];
    }
    else if ([_callReceiver isGroupType])
    {
        return [NSString stringWithFormat:@"正在呼叫%@", [_callReceiver showTitle]];
    }
    return nil;
    
}

- (void)addOwnViews
{
    self.backgroundColor = [UIColor clearColor];
    
    _userIcon = [[UIImageView alloc] init];
    _userIcon.layer.cornerRadius = 30;
    _userIcon.layer.masksToBounds = YES;
    
    [self addSubview:_userIcon];
    
    _userName = [[UILabel alloc] init];
    _userName.textColor = [UIColor whiteColor];
    _userName.textAlignment = NSTextAlignmentCenter;
    
    _userName.font = kAppMiddleTextFont;
    [self addSubview:_userName];
    
    _callTip = [[UILabel alloc] init];
    _callTip.textColor = [UIColor whiteColor];
    _callTip.textAlignment = NSTextAlignmentCenter;
    
    _callTip.font = kAppSmallTextFont;
    [self addSubview:_callTip];
}

- (void)configOwnViewsWith:(IMAUser *)callReceiver
{
    _callReceiver = callReceiver;
    [self configOwnViews];
}

- (void)configOwnViews
{
    _userIcon.image = [self callReceiverIcon];
    _userName.text = [self callReceiverName];
    _callTip.text = [self callReceiverDesc];
}
- (void)relayoutFrameOfSubViews
{
    [_userIcon sizeWith:CGSizeMake(60, 60)];
    [_userIcon alignParentCenter];
    
    [_userName sizeWith:CGSizeMake(self.bounds.size.width, 20)];
    [_userName layoutBelow:_userIcon margin:kDefaultMargin];
    
    [_callTip sameWith:_userName];
    [_callTip alignParentBottom];
}
@end


@implementation TIMCallBottomView

- (instancetype)initWith:(IMAUser *)user
{
    if (self = [super initWithFrame:CGRectZero])
    {
        _callReceiver = user;
        [self addOwnViews];
        [self configOwnViews];
    }
    return self;
}
- (void)addOwnViews
{
    
    UIImage *normal = [UIImage imageNamed:@"call_normal"];
    UIImage *high = [UIImage imageNamed:@"call_pressed"];
    
    ImageTitleButton *ans = [self createButton:[UIImage imageNamed:@"dial_icon"] selected:nil highImage:nil title:@"接听" action:@selector(answerPhone:)];
    ans.imageSize = CGSizeMake(44, 44);
    _answerCall = ans;
    
    ImageTitleButton *hang = [self createButton:normal selected:nil highImage:high title:@"挂断" action:@selector(hangUpPhone:)];
    hang.imageSize = CGSizeMake(44, 44);
    _hangupCall = hang;
    
}

- (ImageTitleButton *)createButton:(UIImage *)nor selected:(UIImage *)selc highImage:(UIImage *)hig title:(NSString *)title action:(SEL)action
{
    ImageTitleButton *btn = [[ImageTitleButton alloc] initWithStyle:EImageTopTitleBottom];
    if (nor)
    {
        [btn setImage:nor forState:UIControlStateNormal];
    }
    
    if (selc)
    {
        [btn setImage:selc forState:UIControlStateSelected];
    }
    
    if (hig)
    {
        [btn setImage:hig forState:UIControlStateHighlighted];
    }
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setTitleColor:kWhiteColor forState:UIControlStateNormal];
    btn.titleLabel.font = kAppSmallTextFont;
    [self addSubview:btn];
    return btn;
}

- (void)answerPhone:(UIButton *)btn
{
    [_delegate onCallBottomViewAnswer:self];
}

- (void)refuesPhone:(UIButton *)btn
{
    [_delegate onCallBottomViewRefuse:self];
}


- (void)hangUpPhone:(UIButton *)btn
{
    [_delegate onCallBottomViewHangUp:self];
}

- (void)onClikcMic:(UIButton *)btn
{
    [_delegate onCallBottomViewClickMic:self];
}

- (void)onClikcCamera:(UIButton *)btn
{
    [self showBeauty:_beautyButton.hidden];
    [_delegate onCallBottomViewClickCamera:self];
}

- (void)onClikcBeauty:(UIButton *)btn
{
    [_delegate onCallBottomViewClickBeauty:self];
}

- (void)onClikcSwitchCamera:(UIButton *)btn
{
    [_delegate onCallBottomViewClickSwitchCamera:self];
}

- (void)onClikcSpeaker:(UIButton *)btn
{
    [_delegate onCallBottomViewClickSpeaker:self];
}

- (void)onClikcInvite:(UIButton *)btn
{
    [_delegate onCallBottomViewClickInvite:self];
}

- (void)onClikcScale:(UIButton *)btn
{
    [_delegate onCallBottomViewClickScale:self];
}


- (void)relayoutFrameOfSubViews
{
    if (_answerCall)
    {
        NSInteger mar = (self.bounds.size.width - 80 * 2) / 3;
        CGRect rect = CGRectInset(self.bounds, 0, (self.bounds.size.height - 80)/2);
        
        [self alignSubviews:@[_answerCall, _hangupCall] horizontallyWithPadding:mar margin:mar inRect:rect];
    }
    else
    {
        CGRect rect = self.bounds;
        rect.size.height /= 2;
        
        if (_beautyButton.hidden)
        {
            NSInteger mar = (self.bounds.size.width - 70 * 3) / 4;
            [self alignSubviews:@[_micButton, _cameraButton, _speakerButton] horizontallyWithPadding:mar margin:mar inRect:CGRectInset(rect, 0, (rect.size.height - 60)/2)];
            
            _beautyButton.frame = _speakerButton.frame;
            _switchCameraButton.frame = _beautyButton.frame;
            
            rect.origin.y += rect.size.height;
            [self alignSubviews:@[_inviteButton, _hangupCall, _scaleButton] horizontallyWithPadding:mar margin:mar inRect:CGRectInset(rect, 0, (rect.size.height - 90)/2)];
        }
        else
        {
            NSInteger mar = (self.bounds.size.width - 60 * 5) / 6;
            [self alignSubviews:@[_micButton, _cameraButton, _switchCameraButton, _beautyButton, _speakerButton] horizontallyWithPadding:mar margin:mar inRect:CGRectInset(rect, 0, (rect.size.height - 60)/2)];
            
            NSInteger mar2 = (self.bounds.size.width - 70 * 3) / 4;
            rect.origin.y += rect.size.height;
            [self alignSubviews:@[_inviteButton, _hangupCall, _scaleButton] horizontallyWithPadding:mar2 margin:mar2 inRect:CGRectInset(rect, 0, (rect.size.height - 90)/2)];
        }
    }
    
}

// 切换到接通状态
- (void)changeToConnected
{
    [_answerCall removeFromSuperview];
    _answerCall = nil;
    
    [_hangupCall removeFromSuperview];
    _hangupCall = nil;
    
    _micButton = [self createButton:[UIImage imageNamed:@"mic"] selected:[UIImage imageNamed:@"mic_shut"] highImage:[UIImage imageNamed:@"mic_click"] title:@"静音" action:@selector(onClikcMic:)];
    _cameraButton = [self createButton:[UIImage imageNamed:@"camera_off"] selected:[UIImage imageNamed:@"camera_on"] highImage:[UIImage imageNamed:@"camera_click"] title:@"摄像头" action:@selector(onClikcCamera:)];
    
    _beautyButton = [self createButton:[UIImage imageNamed:@"beauty"] selected:nil highImage:[UIImage imageNamed:@"beauty_hover"] title:@"美颜" action:@selector(onClikcBeauty:)];
    _beautyButton.hidden = YES;
    
    _switchCameraButton = [self createButton:[UIImage imageNamed:@"switchcamera"] selected:nil highImage:nil title:@"切换" action:@selector(onClikcSwitchCamera:)];
    _switchCameraButton.hidden = YES;
    
    _speakerButton = [self createButton:[UIImage imageNamed:@"speaker_disable"] selected:[UIImage imageNamed:@"speaker_enable"] highImage:nil title:@"扬声器" action:@selector(onClikcSpeaker:)];
    
    ImageTitleButton *invite = [self createButton:[UIImage imageNamed:@"call_invite"] selected:nil highImage:nil title:@"邀请" action:@selector(onClikcInvite:)];
    invite.imageSize = CGSizeMake(44, 44);
    _inviteButton = invite;
    
    ImageTitleButton *hang = [self createButton:[UIImage imageNamed:@"call_normal"] selected:nil highImage:[UIImage imageNamed:@"call_pressed"] title:@"挂断" action:@selector(hangUpPhone:)];
    hang.imageSize = CGSizeMake(44, 44);
    _hangupCall = hang;
    
    ImageTitleButton *scale = [self createButton:[UIImage imageNamed:@"call_scale"] selected:nil highImage:[UIImage imageNamed:@"call_scale_press"] title:@"收起" action:@selector(onClikcScale:)];
    scale.imageSize = CGSizeMake(44, 44);
    _scaleButton = scale;
    [self relayoutFrameOfSubViews];
}

- (void)showBeauty:(BOOL)show
{
    _beautyButton.hidden = !show;
    _switchCameraButton.hidden = !show;
    [UIView animateWithDuration:0.25 animations:^{
        [self relayoutFrameOfSubViews];
    }];
}

- (void)configWithEngine:(TCAVLiveRoomEngine *)engine
{
    _micButton.selected = [engine isMicEnable];
    _cameraButton.selected = [engine isCameraEnable];
    _beautyButton.hidden = ![engine isCameraEnable];
    _switchCameraButton.hidden = _beautyButton.hidden;
    _speakerButton.selected = [engine isSpeakerEnable];
    
    [self relayoutFrameOfSubViews];
}




@end
