//
//  IMAUser+TCAVAble.h
//  TIMChat
//
//  Created by AlexiChen on 16/6/3.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAUser.h"

@interface IMAUser (AVMultiUserAble)<AVMultiUserAble>

@property (nonatomic, assign) NSInteger avCtrlState;

@property (nonatomic, assign) NSInteger avMultiUserState;

@property (nonatomic, assign) CGRect avInteractArea;

@property (nonatomic, weak) UIView *avInvisibleInteractView;

- (BOOL)isCurrentLiveHost:(id<AVRoomAble>)room;

- (instancetype)initWithIMUserAble:(id<IMUserAble>)imuser;
@end