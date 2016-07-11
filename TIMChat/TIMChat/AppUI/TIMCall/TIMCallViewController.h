//
//  TIMCallViewController.h
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TIMCallViewController : TCAVCallViewController<TIMCallBottomViewDelegate, TCShowMultiViewDelegate>
{
@protected
    UIImageView             *_callBackground;
    
    TCShowMultiView         *_multiView;
@protected
    IMAUser                 *_callReceiver;
    
@protected
    NSTimer                 *_callTimer;
    
@protected
    AVAudioPlayer           *_callBellPlayer;
    
@protected
    NSMutableDictionary     *_userList;     // 进入房间的列表，不包括自己
    
@protected
    UIView                  *_callFloatView;    // 不加入到self.view
}

@property (nonatomic, weak) id<AVIMCallHandlerAble> callMsgHandler;

@property (nonatomic, assign) BOOL isInviteCall;

@property (nonatomic, strong) IMAUser *callReceiver;

@property (nonatomic, strong) UIView *callTopView;

@property (nonatomic, strong) UIImageView *imgIconView;

@property (nonatomic, strong) UIView *callBottomView;

@property (nonatomic, assign) TIMCallPressentType pressentType;

@property (nonatomic, assign) CGPoint lastDismissPoint;

@property (nonatomic, strong) UIView *callFloatView;


- (void)starLayerAnimation;

- (void)stopLayerAnimation;

- (UIImage *)callReceiverIcon;

- (id<IMUserAble>)mainUser;

@end
