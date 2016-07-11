//
//  TIMCallTopView.h
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TIMCallTopView : UIView
{
@protected
    UIImageView *_userIcon;
    UILabel     *_userName;
    UILabel     *_callTip;

@protected
    NSInteger   _connectedTime;
    NSTimer     *_connectedTimer;
@protected
    __weak IMAUser *_callReceiver;
}
@property (nonatomic, readonly) UIImageView *userIcon;
@property (nonatomic, readonly) UILabel *userName;
@property (nonatomic, readonly) UILabel *callTip;

- (instancetype)initWith:(IMAUser *)user;

- (void)configOwnViewsWith:(IMAUser *)callReceiver;
- (void)startConnectedTimer;
- (void)stopConnectedTimer;
@end


@class TIMCallBottomView;

@protocol TIMCallBottomViewDelegate <NSObject>

@required

- (void)onCallBottomViewRefuse:(TIMCallBottomView *)view;
- (void)onCallBottomViewAnswer:(TIMCallBottomView *)view;

- (void)onCallBottomViewClickMic:(TIMCallBottomView *)view;
- (void)onCallBottomViewClickCamera:(TIMCallBottomView *)view;
- (void)onCallBottomViewClickBeauty:(TIMCallBottomView *)view;
- (void)onCallBottomViewClickSwitchCamera:(TIMCallBottomView *)view;
- (void)onCallBottomViewClickSpeaker:(TIMCallBottomView *)view;
- (void)onCallBottomViewClickInvite:(TIMCallBottomView *)view;
- (void)onCallBottomViewClickScale:(TIMCallBottomView *)view;
- (void)onCallBottomViewHangUp:(TIMCallBottomView *)view;

@end


@interface TIMCallBottomView : UIView
{
@protected
    UIButton    *_answerCall;
    UIButton    *_hangupCall;
    
@protected
    UIButton    *_micButton;
    UIButton    *_cameraButton;
    UIButton    *_speakerButton;
    UIButton    *_inviteButton;
    UIButton    *_scaleButton;
    
@protected
    __weak IMAUser *_callReceiver;
}

@property (nonatomic, weak) id<TIMCallBottomViewDelegate> delegate;


@property (nonatomic, readonly) UIButton *answerCall;
@property (nonatomic, readonly) UIButton *hangupCall;

@property (nonatomic, readonly) UIButton *micButton;
@property (nonatomic, readonly) UIButton *cameraButton;
@property (nonatomic, readonly) UIButton *beautyButton;
@property (nonatomic, readonly) UIButton *switchCameraButton;
@property (nonatomic, readonly) UIButton *speakerButton;
@property (nonatomic, readonly) UIButton *inviteButton;
@property (nonatomic, readonly) UIButton *scaleButton;

- (instancetype)initWith:(IMAUser *)user;

- (void)configWithEngine:(TCAVLiveRoomEngine *)engine;

// 切换到接通状态
- (void)changeToConnected;

- (void)showBeauty:(BOOL)show;

@end
