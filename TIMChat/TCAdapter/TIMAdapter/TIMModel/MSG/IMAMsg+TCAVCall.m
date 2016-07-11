//
//  IMAMsg+TCAVCall.m
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAMsg+TCAVCall.h"

@implementation IMAMsg (TCAVCall)


static NSString *const kIMAMsgCustomCMD = @"kIMAMsgCustomCMD";

- (AVIMCMD *)customCMD
{
    return objc_getAssociatedObject(self, (__bridge const void *)kIMAMsgCustomCMD);
}

- (void)setCustomCMD:(AVIMCMD *)customCMD
{
    objc_setAssociatedObject(self, (__bridge const void *)kIMAMsgCustomCMD, customCMD, OBJC_ASSOCIATION_RETAIN);
}

+ (instancetype)msgWithCall:(AVIMCMD *)cmd
{
    if (cmd)
    {
        TIMCustomElem *elem = [[TIMCustomElem alloc] init];
        elem.data = [cmd packToSendData];
        
        TIMMessage *msg = [[TIMMessage alloc] init];
        [msg addElem:elem];
        IMAMsg *imamsg = [[IMAMsg alloc] initWith:msg type:EIMAMSG_Call];
        return imamsg;
    }
    return nil;
}


- (BOOL)isTIMCallMsg
{
    if (self.customCMD)
    {
        return YES;
    }
    
    if ([self isCustomMsg] && [self isVailedType])
    {
        if ([self.msg elemCount] > 0)
        {
            TIMCustomElem *elem = (TIMCustomElem *)[self.msg getElem:0];
            AVIMCMD *cmd = [AVIMCMD parseCustom:elem];
            if (cmd)
            {
                // 缺少陌生人互起操作
                TIMConversationType type = _msg.getConversation.getType;
                if (type == TIM_C2C)
                {
                    id<IMUserAble> profile = [_msg GetSenderProfile];
                    if (!profile)
                    {
                        // TODO: 身份信息为空下处理
//                        // C2C时获取到消息GetSenderProfile为空
//                        NSString *recv = [[_msg getConversation] getReceiver];
//                        profile = [self syncGetC2CUserInfo:recv];
                    }
                    
                    cmd.sender = [[IMAPlatform sharedInstance].contactMgr getUserByUserId:[profile imUserId]];
                }
                else if (type == TIM_GROUP)
                {
                    
                    id<IMUserAble> info = [_msg GetSenderProfile];
                    if (!info)
                    {
                        info = [_msg GetSenderGroupMemberProfile];
                    }
                    
                    cmd.sender = [[IMAPlatform sharedInstance].contactMgr getUserByUserId:[info imUserId]];
                }
                self.customCMD = cmd;
                return YES;
            }
        }
    }
    return NO;
}

@end
