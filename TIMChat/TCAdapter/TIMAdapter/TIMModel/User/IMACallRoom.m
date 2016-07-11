//
//  IMACallRoom.m
//  TIMChat
//
//  Created by AlexiChen on 16/6/7.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMACallRoom.h"

@implementation IMACallRoom

// 聊天室Id
- (void)setLiveIMChatRoomId:(NSString *)liveIMChatRoomId
{
    self.callGroupID = liveIMChatRoomId;
}

- (NSString *)liveIMChatRoomId
{
    return self.callGroupID;
}

// 当前主播信息
- (id<IMUserAble>)liveHost
{
    return _callSponsor;
}

// 直播房间Id
- (int)liveAVRoomId
{
    return _callRoomID;
}

// 直播标题，用于创建直播IM聊天室，不能为空
- (NSString *)liveTitle
{
    return self.callRoomTitle;
}

@end
