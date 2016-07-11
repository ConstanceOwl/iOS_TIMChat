//
//  IMAConversationManager.m
//  TIMAdapter
//
//  Created by AlexiChen on 16/2/18.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAConversationManager.h"


@implementation IMAConversationChangedNotifyItem

- (instancetype)initWith:(IMAConversationChangedNotifyType)type
{
    if (self = [super init])
    {
        _type = type;
    }
    return self;
}

- (NSNotification *)changedNotification
{
    NSNotification *notify = [NSNotification notificationWithName:[self notificationName] object:self];
    return notify;
}
- (NSString *)notificationName
{
    return [NSString stringWithFormat:@"IMAConversationChangedNotification_%d", (int)_type];
}

@end

@implementation IMAConversationManager


- (instancetype)init
{
    if (self = [super init])
    {
        _conversationList = [[CLSafeSetArray alloc] init];
    }
    return self;
}

- (void)releaseChattingConversation
{
    [_chattingConversation releaseConversation];
    _chattingConversation = nil;
}

- (void)asyncUpdateConversationListComplete
{
    if (_refreshStyle == EIMARefresh_Wait)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 说明有更新过来，再更新一次
            [self asyncConversationList];
            _refreshStyle = EIMARefresh_None;
        });
    }
    else
    {
        _refreshStyle = EIMARefresh_None;
        [self updateOnLocalMsgComplete];
    }
}

- (void)asyncUpdateConversationList
{
    NSInteger unRead = 0;
    
    NSMutableArray *conversationList = [NSMutableArray array];
    
//2.0之前的版本不支持 getConversationList 接口
#if kGetConverSationList
    conversationList = [[TIMManager sharedInstance] getConversationList];
#else
    int cnt = [[TIMManager sharedInstance] ConversationCount];
    for (int index=0; index < cnt; index++)
    {
        TIMConversation *conversation = [[TIMManager sharedInstance] getConversationByIndex:index];
        [conversationList addObject:conversation];
    }
#endif

    for (TIMConversation *conversation in conversationList)
    {
        IMAConversation *conv = nil;
        if ([conversation getType] == TIM_SYSTEM)
        {
#if kSupportCustomConversation
            // 可能返回空
            conv = [[IMACustomConversation alloc] initWith:conversation];
#else
            continue;
#endif
        }
        else
        {
            conv = [[IMAConversation alloc] initWith:conversation];
        }
        
        if (conv)
        {
            [_conversationList addObject:conv];
        }
        
        if (_chattingConversation && [_chattingConversation isEqual:conv])
        {
            [conv copyConversationInfo:_chattingConversation];
            // 防止因中途在聊天时，出现onrefresh回调
            _chattingConversation = conv;
        }
        else
        {
            if (conv)
            {
                unRead += [conversation getUnReadMessageNum];
            }
        }
    }
    
    [self asyncUpdateConversationListComplete];
    
    if (unRead != _unReadMessageCount)
    {
        self.unReadMessageCount = unRead;
    }
    DebugLog(@"==========>>>>>>>>>asyncUpdateConversationList Complete");
}

- (void)asyncConversationList
{
    DebugLog(@"==========>>>>>>>>>asyncConversationList");
    // 因OnRefresh里面不定期有回调，能过这种处理，避免_conversationList修改导致界面Crash
    if (_refreshStyle == EIMARefresh_None)
    {
        _refreshStyle = EIMARefresh_ING;
        [self asyncUpdateConversationList];
    }
    else
    {
        _refreshStyle = EIMARefresh_Wait;
    }
}

- (void)addConversationChangedObserver:(id)observer handler:(SEL)selector forEvent:(NSUInteger)eventID
{
    NSUInteger op = EIMAContact_AddNewSubGroup;
    do
    {
        if (op & eventID)
        {
            NSString *notification = [NSString stringWithFormat:@"IMAConversationChangedNotification_%d", (int)op];
            [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:notification object:nil];
            eventID -= op;
        }
        op = op << 1;
        
    } while (eventID > 0);
}

- (void)removeConversationChangedObser:(id)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

- (void)deleteConversation:(IMAConversation *)conv needUIRefresh:(BOOL)need
{
    NSInteger index = [_conversationList indexOfObject:conv];
    if (index >= 0 && index < [_conversationList count])
    {
        [conv setReadAllMsg];
        self.unReadMessageCount -= [conv unReadCount];
        [_conversationList removeObject:conv];
        
        if ([conv type] == TIM_C2C)
        {
            [[TIMManager sharedInstance] deleteConversation:[conv type] receiver:[conv receiver]];
        }
        else if ([conv type] == TIM_GROUP)
        {
            [[TIMManager sharedInstance] deleteConversationAndMessages:[conv type] receiver:[conv receiver]];
        }
        
        if (need)
        {
            [self updateOnDelete:conv atIndex:index];
        }
    }
}

- (IMAConversation *)chatWith:(IMAUser *)user
{
    TIMConversation *conv = nil;
    if ([user isC2CType])
    {
        conv = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:[user userId]];
    }
    else if([user isGroupType])
    {
        conv = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:[user userId]];
    }
    else if ([user isSystemType])
    {
        // 暂不支持System消息
        return nil;
    }
    
    self.unReadMessageCount -= [conv getUnReadMessageNum];

    [conv setReadMessage];
    
    if (conv)
    {
        IMAConversation *temp = [[IMAConversation alloc] initWith:conv];
        
        NSInteger index = [_conversationList indexOfObject:temp];
        if (index >= 0 && index < _conversationList.count)
        {
            IMAConversation *ret = [_conversationList objectAtIndex:index];
            _chattingConversation = ret;
            _chattingConversation.lastMessage = _chattingConversation.lastMessage;
            return ret;
        }
        
        _chattingConversation = temp;
        return temp;
    }
    return nil;
}

// 主用要于自定义类型
- (IMAConversation *)queryConversationWithType:(IMAConType)user
{
    //    for (NSInteger i = 0; i < [_conversationList count]; i++)
    //    {
    //        IMAConversation *conv = [_conversationList objectAtIndex:i];
    //        if ([conv isChatWith:user])
    //        {
    //            return conv;
    //        }
    //    }
    return nil;
}

- (IMAConversation *)queryConversationWith:(IMAUser *)user
{
    if (user)
    {
        for (NSInteger i = 0; i < [_conversationList count]; i++)
        {
            IMAConversation *conv = [_conversationList objectAtIndex:i];
            if ([conv isChatWith:user])
            {
                return conv;
            }
        }
    }
    return nil;
}

- (void)removeConversationWith:(IMAUser *)user
{
    for (NSInteger i = 0; i < [_conversationList count]; i++)
    {
        IMAConversation *conv = [_conversationList objectAtIndex:i];
        if ([conv isChatWith:user])
        {
            if (conv == _chattingConversation)
            {
                // TODO:通知界面
                [[IMAAppDelegate sharedAppDelegate] popToRootViewController];
            }
            [_conversationList removeObjectAtIndex:i];
            self.unReadMessageCount -= [conv unReadCount];
            
            if ([conv type] == TIM_C2C)
            {
                [[TIMManager sharedInstance] deleteConversation:[conv type] receiver:[conv receiver]];
            }
            else if ([conv type] == TIM_GROUP)
            {
                [[TIMManager sharedInstance] deleteConversationAndMessages:[conv type] receiver:[conv receiver]];
            }
            
            [self updateOnDelete:conv atIndex:i];
            break;
        }
    }
}

- (void)updateConversationWith:(IMAUser *)user
{
    IMAConversation *conv = [self queryConversationWith:user];
    if (conv)
    {
        [self updateOnConversationChanged:conv];
    }
}

- (NSInteger)insertPosition
{
    IMAPlatform *mp = [IMAPlatform sharedInstance];
    if (mp.isConnected)
    {
        if ([_conversationList count] > 1)
        {
            return 1;
        }
    }
    return 0;
}


/**
 *  新消息通知
 *
 *  @param msgs 新消息列表，TIMMessage 类型数组
 */
- (void)onNewMessage:(NSArray *)msgs
{
    for (TIMMessage *msg in msgs)
    {
        IMAMsg *imamsg = [IMAMsg msgWith:msg];
        
        TIMConversation *conv = [msg getConversation];
        BOOL isSystemMsg = [conv getType] == TIM_SYSTEM;
        
        BOOL isAddGroupReq = NO;
        BOOL isAddFriendReq = NO;
        BOOL isContinue = YES;
        if (isSystemMsg)
        {
            int elemCount = [msg elemCount];
            for (int i = 0; i < elemCount; i++)
            {
                TIMElem *elem = [msg getElem:i];
                if ([elem isKindOfClass:[TIMGroupSystemElem class]])
                {
                    TIMGroupSystemElem *gse = (TIMGroupSystemElem *)elem;
                    if (gse.type == TIM_GROUP_SYSTEM_ADD_GROUP_REQUEST_TYPE)
                    {
//                        [self onAddGroupRequest:gse];
                        isContinue = NO;
                        isAddGroupReq = YES;
                    }
                }
                else if ([elem isKindOfClass:[TIMSNSSystemElem class]])
                {
                    TIM_SNS_SYSTEM_TYPE type = ((TIMSNSSystemElem *)elem).type;
                    if (type == TIM_SNS_SYSTEM_ADD_FRIEND_REQ)
                    {
                        if (!msg.isSelf)
                        {
//                            [self onAddFreindRequest:(TIMSNSSystemElem *)elem];
                            isContinue = NO;
                            isAddFriendReq = YES;
                        }
                    }
                }
            }
//            continue;
            if (isContinue)
            {
                continue;
            }
        }
//#if kSupportCustomConversation
//#else
//        if (isSystemMsg)
//        {
//            continue;
//        }
//#endif
        

        BOOL updateSucc = NO;
        IMAConversation *imamsgConv = nil;
        for (NSInteger i = 0; i < [_conversationList count]; i++)
        {
            IMAConversation *imaconv = [_conversationList objectAtIndex:i];
            NSString *imaconvReceiver = [imaconv receiver];
            if (imaconv.type == [conv getType] && ([imaconvReceiver isEqualToString:[conv getReceiver]] || [imaconvReceiver isEqualToString:[IMACustomConversation getCustomConversationID:imamsg]]))
            {
                if (imaconv == _chattingConversation)
                {
                    [conv setReadMessage];
                    imaconv.lastMessage = imamsg;
                    [_chattingConversation onReceiveNewMessage:imamsg];
                }
                else
                {
                    imaconv.lastMessage = imamsg;
                    if (isSystemMsg)
                    {
                        __weak IMAConversationManager *ws = self;
                        // 系统消息
                        IMACustomConversation *customConv = (IMACustomConversation *)imaconv;
                        [customConv saveMessage:imamsg succ:^(int newUnRead) {
                            ws.unReadMessageCount += newUnRead;
                            [ws updateOnChat:imaconv moveFromIndex:i];
                        }];
                    }
                    else
                    {
                        imaconv.lastMessage = imamsg;
                        //如果是自己发出去的消息，一定是已读(这里判断主要是用在多终端登录的情况下)
                        if (![imamsg isMineMsg])
                        {
                            self.unReadMessageCount++;
                        }
                        [self updateOnChat:imaconv moveFromIndex:i];
                    }
                }
                updateSucc = YES;
                imamsgConv = imaconv;
                break;
            }
        }
        
        if (!updateSucc && _refreshStyle == EIMARefresh_None)
        {
            if (isSystemMsg)
            {
                NSString *receiverid = [IMACustomConversation getCustomConversationID:imamsg];
                TIMConversation *imconv = [[TIMManager sharedInstance] getConversation:TIM_SYSTEM receiver:receiverid];
                [imconv setReadMessage];
                // 说明会话列表中没有该会话，新生建会话，并更新到
                IMACustomConversation *temp = [[IMACustomConversation alloc] initWith:imconv andMsg:imamsg];
                if (temp)
                {
                    __weak IMAConversationManager *ws = self;
                    [temp saveMessage:imamsg succ:^(int newUnRead) {
                        ws.unReadMessageCount += newUnRead;
                    }];
                    [_conversationList insertObject:temp atIndex:[self insertPosition]];
                    // self.unReadMessageCount++;
                    DebugLog(@"====================>>>>>>System updateOnNewConversation");
                    [self updateOnNewConversation:temp];
                    DebugLog(@"====================>>>>>>System updateOnNewConversation<<<<<===============");
                }
            }
            else
            {
                // 说明会话列表中没有该会话，新生建会话，并更新到
                IMAConversation *temp = [[IMAConversation alloc] initWith:conv];
                temp.lastMessage = imamsg;
                imamsgConv = temp;
                [_conversationList insertObject:temp atIndex:[self insertPosition]];
                self.unReadMessageCount++;
                DebugLog(@"====================>>>>>>updateOnNewConversation");
                [self updateOnNewConversation:temp];
                DebugLog(@"====================>>>>>>updateOnNewConversation<<<<<===============");
            }
        }
        
        
        if (imamsg.type == EIMAMSG_Custom || imamsg.type == EIMAMSG_Call)
        {
            [self handleCustomMsg:imamsg inConversation:imamsgConv];
        }
    }
}

- (void)handleCustomMsg:(IMAMsg *)imamsg inConversation:(IMAConversation *)conv
{
        // 当前App在前台
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
        {
            // 解析是否为电话命令
            BOOL isCall = [imamsg isTIMCallMsg];
            if (isCall)
            {
                AVIMCMD *cmd = imamsg.customCMD;
                
                [[IMAPlatform sharedInstance] onRecvCall:cmd conversation:conv isFromChatting:[conv isEqual:_chattingConversation]];
            }
        }
        else
        {
            // 作后台LocalNotification处理
        }
    
}

//申请加群请求
- (void)onAddGroupRequest:(TIMGroupSystemElem *)item
{
//    IMAGroup *tempGroup = [[IMAGroup alloc] initWith:item.group];
//    IMAGroup *group = (IMAGroup *)[[IMAPlatform sharedInstance].contactMgr isContainUser:tempGroup];
//    NSString *message = [NSString stringWithFormat:@"%@申请加入群:%@\n申请理由:%@", item.user, group.groupInfo.groupName, item.msg];
//    
//    UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"加群申请" message:message cancelButtonTitle:@"忽略" otherButtonTitles:@[@"同意",@"拒绝"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//        if (buttonIndex == 1)//同意
//        {
//            [[IMAPlatform sharedInstance] asyncAcceptAddGroup:item succ:^{
//                
//            } fail:nil];
//        }
//        else if (buttonIndex == 2)//拒绝
//        {
//            [[IMAPlatform sharedInstance] asyncRefuseAddGroup:item succ:^{
//                
//            } fail:nil];
//        }
//    }];
//    [alert show];
}

- (void)onAddFreindRequest:(TIMSNSSystemElem *)elem
{
}

@end


@implementation IMAConversationManager (Protected)

- (void)onConnect
{
    // 删除
    IMAConnectConversation *conv = [[IMAConnectConversation alloc] init];
    NSInteger index = [_conversationList indexOfObject:conv];
    if (index >= 0 && index < [_conversationList count])
    {
        [_conversationList removeObject:conv];
        [self updateOnDelete:conv atIndex:index];
    }
}
- (void)onDisConnect
{
    
    // 插入一个网络断开的fake conversation
    IMAConnectConversation *conv = [[IMAConnectConversation alloc] init];
    NSInteger index = [_conversationList indexOfObject:conv];
    if (!(index >= 0 && index < [_conversationList count]))
    {
        [_conversationList insertObject:conv atIndex:0];
        [self updateOnNewConversation:conv];
    }
}

- (void)updateOnChat:(IMAConversation *)conv moveFromIndex:(NSUInteger)index
{
    NSInteger toindex = [self insertPosition];
    
    if (index != toindex)
    {
        [_conversationList removeObjectAtIndex:index];
        
        [_conversationList insertObject:conv atIndex:toindex];
        
        
        // 更新界面
        IMAConversationChangedNotifyItem *item = [[IMAConversationChangedNotifyItem alloc] initWith:EIMAConversation_BecomeActiveTop];
        item.conversation = conv;
        item.index = index;
        item.toIndex = toindex;
        
        if (_conversationChangedCompletion)
        {
            _conversationChangedCompletion(item);
        }
        
        [[NSNotificationQueue defaultQueue] enqueueNotification:[item changedNotification] postingStyle:NSPostWhenIdle];
    }
    
    
}

- (void)updateOnDelete:(IMAConversation *)conv atIndex:(NSUInteger)index
{
    // 更新界面
    IMAConversationChangedNotifyItem *item = [[IMAConversationChangedNotifyItem alloc] initWith:EIMAConversation_DeleteConversation];
    item.conversation = conv;
    item.index = index;
    if (_conversationChangedCompletion)
    {
        _conversationChangedCompletion(item);
    }
    
    [[NSNotificationQueue defaultQueue] enqueueNotification:[item changedNotification] postingStyle:NSPostWhenIdle];
}

- (void)updateOnAsyncLoadContactComplete
{
    // 通知更新界面
    IMAConversationChangedNotifyItem *item = [[IMAConversationChangedNotifyItem alloc] initWith:EIMAConversation_SyncLocalConversation];
    if (_conversationChangedCompletion)
    {
        _conversationChangedCompletion(item);
    }
    [[NSNotificationQueue defaultQueue] enqueueNotification:[item changedNotification] postingStyle:NSPostWhenIdle];
}

- (void)updateOnLocalMsgComplete
{
    // 更新界面
    IMAConversationChangedNotifyItem *item = [[IMAConversationChangedNotifyItem alloc] initWith:EIMAConversation_SyncLocalConversation];
    if (_conversationChangedCompletion)
    {
        _conversationChangedCompletion(item);
    }
    [[NSNotificationQueue defaultQueue] enqueueNotification:[item changedNotification] postingStyle:NSPostWhenIdle];
}


- (void)updateOnLastMessageChanged:(IMAConversation *)conv
{
    if ([_chattingConversation isEqual:conv])
    {
        NSInteger index = [_conversationList indexOfObject:conv];
        NSInteger toindex = [self insertPosition];
        if (index > 0 && index < [_conversationList count])
        {
            [_conversationList removeObject:conv];
            [_conversationList insertObject:conv atIndex:toindex];
            [self updateOnChat:conv moveFromIndex:index toIndex:toindex];
        }
        else if (index < 0 || index > [_conversationList count])
        {
            [_conversationList insertObject:conv atIndex:[self insertPosition]];
            [self updateOnNewConversation:conv];
        }
        else
        {
            // index == 0 不作处理
        }
    }
}

- (void)updateOnChat:(IMAConversation *)conv moveFromIndex:(NSUInteger)index toIndex:(NSInteger)toIdx
{
    // 更新界面
    IMAConversationChangedNotifyItem *item = [[IMAConversationChangedNotifyItem alloc] initWith:EIMAConversation_BecomeActiveTop];
    item.conversation = conv;
    item.index = index;
    item.toIndex = toIdx;
    
    if (_conversationChangedCompletion)
    {
        _conversationChangedCompletion(item);
    }
    
    [[NSNotificationQueue defaultQueue] enqueueNotification:[item changedNotification] postingStyle:NSPostWhenIdle];
}

- (void)updateOnNewConversation:(IMAConversation *)conv
{
    // 更新界面
    IMAConversationChangedNotifyItem *item = [[IMAConversationChangedNotifyItem alloc] initWith:EIMAConversation_NewConversation];
    item.conversation = conv;
    item.index = [_conversationList indexOfObject:conv];
    
    if (_conversationChangedCompletion)
    {
        _conversationChangedCompletion(item);
    }
    
    [[NSNotificationQueue defaultQueue] enqueueNotification:[item changedNotification] postingStyle:NSPostWhenIdle];
}

- (void)updateOnConversationChanged:(IMAConversation *)conv
{
    IMAConversationChangedNotifyItem *item = [[IMAConversationChangedNotifyItem alloc] initWith:EIMAConversation_ConversationChanged];
    item.conversation = conv;
    item.index = [_conversationList indexOfObject:conv];
    
    if (_conversationChangedCompletion)
    {
        _conversationChangedCompletion(item);
    }
    [[NSNotificationQueue defaultQueue] enqueueNotification:[item changedNotification] postingStyle:NSPostWhenIdle];
}

@end
