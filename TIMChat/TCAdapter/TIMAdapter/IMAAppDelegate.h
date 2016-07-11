//
//  IMAAppDelegate.h
//  TIMChat
//
//  Created by AlexiChen on 16/2/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "BaseAppDelegate.h"

// 该类主要是把集成IMSDK常用的操作与App相关事件关联起来
// 方便用户继承
#if kSupportCallScene
@protocol AVIMCallHandlerAble;
@class TCAVCallViewController;
#endif

@interface IMAAppDelegate : BaseAppDelegate

#if kSupportCallScene
// 呼叫发起
- (TCAVCallViewController *)presentCallViewControllerWith:(IMAUser *)user type:(BOOL)isVoice callMsgHandler:(id<AVIMCallHandlerAble>)callHandler;

// 被呼叫收到消息后展示
- (TCAVCallViewController *)presentCommingCallViewControllerWith:(AVIMCMD *)callUser conversation:(IMAConversation *)conv isFromChatting:(BOOL)isChatting;
#endif

@end
