//
//  IMAConversation+TCAVCall.m
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAConversation+TCAVCall.h"

@implementation IMAConversation (TCAVCall)

- (void)sendCallMsg:(AVIMCMD *)callCmd finish:(CommonFinishBlock)block
{
    if (callCmd)
    {
        if (callCmd.msgType >= AVIMCMD_Call && callCmd.msgType <= AVIMCMD_Call_AllCount)
        {
            if (callCmd.msgType == AVIMCMD_Call_Dialing || callCmd.msgType == AVIMCMD_Call_Disconnected)
            {
                IMAMsg *msg = [IMAMsg msgWithCall:callCmd];
                
                [self addMsgToList:msg];
                
                [msg changeTo:EIMAMsg_Sending needRefresh:NO];
                [_conversation sendMessage:msg.msg succ:^{
                    [msg changeTo:EIMAMsg_SendSucc needRefresh:YES];
                    if (block)
                    {
                        block(YES);
                    }
                } fail:^(int code, NSString *err) {
                    [msg changeTo:EIMAMsg_SendFail needRefresh:YES];
                    DebugLog(@"发送消息失败");
                    [[HUDHelper sharedInstance] tipMessage:IMALocalizedError(code, err)];
                    if (block)
                    {
                        block(NO);
                    }
                }];
            }
            else
            {
                IMAMsg *msg = [IMAMsg msgWithCall:callCmd];
                [_conversation sendOnlineMessage:msg.msg succ:^{
                    if (block)
                    {
                        block(YES);
                    }
                } fail:^(int code, NSString *err) {
                    DebugLog(@"发送消息失败");
                    if (block)
                    {
                        block(NO);
                    }
                }];
            }
            
        }
    }
}

@end
