//
//  IMAMsg+TCAVCall.h
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAMsg.h"

@class AVIMCMD;

@interface IMAMsg (TCAVCall)

@property (nonatomic, strong) AVIMCMD *customCMD;


+ (instancetype)msgWithCall:(AVIMCMD *)cmd;
// 是否是电话消息类型
- (BOOL)isTIMCallMsg;

@end
