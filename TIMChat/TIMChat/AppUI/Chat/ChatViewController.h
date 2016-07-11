//
//  ChatViewController.h
//  TIMChat
//
//  Created by AlexiChen on 16/2/23.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MicroVideoView.h"

@class MyChatToolBarView;

@interface ChatViewController : TableRefreshViewController<MyChatToolBarViewDelegate, MyMoreViewDelegate, MicroVideoDelegate, AVIMCallHandlerAble>
{
@protected
    IMAConversation                     *_conversation;
    
    IMAUser                             *_receiver;
    FBKVOController                     *_receiverKVO;
    
    __weak CLSafeMutableArray           *_messageList;
    
@protected
    MyChatToolBarView                   *_toolbar;
}

- (instancetype)initWith:(IMAUser *)user;

- (void)configWithUser:(IMAUser *)user;

- (void)addChatSettingItem;
- (void)onClickChatSetting;


// 加载历史信息
- (void)loadHistotyMessages;

// 添加收到的信息
- (void)appendReceiveMessage;

- (void)sendMsg:(IMAMsg *)msg;

- (void)updateOnSendMessage:(NSArray *)msglist succ:(BOOL)succ;

@end
