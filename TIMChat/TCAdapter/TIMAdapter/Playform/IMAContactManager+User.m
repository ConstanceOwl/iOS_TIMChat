//
//  IMAContactManager+User.m
//  TIMChat
//
//  Created by AlexiChen on 16/3/22.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAContactManager+User.h"

@implementation IMAContactManager (User)

- (void)asyncModify:(IMAUser *)user remark:(NSString *)remark succ:(TIMSucc)succ fail:(TIMFail)fail
{
    if (!user)
    {
        DebugLog(@"参数有误");
        return;
    }
    
    if ([remark utf8Length] > 96)
    {
        [[HUDHelper sharedInstance] tipMessage:@"备注名过长"];
        return;
    }
    
    
    __weak IMAContactManager *ws = self;
    [[TIMFriendshipManager sharedInstance] SetFriendRemark:user.userId remark:remark succ:^{
        // 更新用户的名称
        user.remark = remark;
        [ws onFriendInfoChanged:user remark:remark];
        if (succ)
        {
            succ();
        }
    } fail:^(int code, NSString *err) {
        DebugLog(@"Fail: %d->%@", code, err);
        [[HUDHelper sharedInstance] tipMessage:IMALocalizedError(code, err)];
        
        if (fail)
        {
            fail(code, err);
        }
    }];
    
}

- (void)asyncModify:(IMAUser *)user subgroup:(IMASubGroup *)sg succ:(TIMFriendSucc)succ fail:(TIMFail)fail
{
    if (!user || !sg)
    {
        DebugLog(@"参数有误");
        return;
    }
    
    
    
    // TODO:等Tom新增默认分组接口
    IMASubGroup *sub = [self subGroupOf:user];
    
    if (!sub)
    {
        // 好友不存在分组中中
        DebugLog(@"参数有误");
        return;
    }
    
    if ([sub isEqual:sg])
    {
    
        [[HUDHelper sharedInstance] tipMessage:@"用户已在该分组"];
        return;
    }
    
    if (sub.isDefaultSubGroup && !sg.isDefaultSubGroup)
    {
        // 从我的好友移动到分组
        [[TIMFriendshipManager sharedInstance] AddFriendsToFriendGroup:sg.name users:@[user.userId] succ:^(NSArray *friends) {
            [[IMAPlatform sharedInstance].contactMgr onMove:user from:sub to:sg];
            if (succ)
            {
                succ(friends);
            }
        } fail:^(int code, NSString *err) {
            DebugLog(@"Fail: %d->%@", code, err);
            [[HUDHelper sharedInstance] tipMessage:IMALocalizedError(code, err)];
            
            if (fail)
            {
                fail(code, err);
            }
        }];

    }
    else if (!sub.isDefaultSubGroup && !sg.isDefaultSubGroup)
    {
        //非默认分组之间的移动有两个步骤
        //1、将用户从当前分组移动到默认分组  2、将用户从默认分组移动到指定分组
        __weak IMASubGroup *wFromSubGroup = sub;
        __weak IMASubGroup *wToSubGroup = sg;
        __weak IMAUser  *wu = user;
        
        [[TIMFriendshipManager sharedInstance] DelFriendsFromFriendGroup:wFromSubGroup.name users:@[wu.userId] succ:^(NSArray *friends) {
            
            //从当前分组移动到默认分组
            [[TIMFriendshipManager sharedInstance] AddFriendsToFriendGroup:wToSubGroup.name users:@[wu.userId] succ:^(NSArray *friends) {
                
                //从默认分组移动到指定分组
                [[IMAPlatform sharedInstance].contactMgr onMove:wu from:wFromSubGroup to:wToSubGroup];
                if (succ)
                {
                    succ(friends);
                }
            } fail:^(int code, NSString *msg) {
                DebugLog(@"Fail: %d->%@", code, msg);
                //
                IMASubGroup *defaultGroup = [[IMAPlatform sharedInstance].contactMgr defaultAddToSubGroup];
                [[IMAPlatform sharedInstance].contactMgr onMove:wu from:wFromSubGroup to:defaultGroup];
                
                NSString *failInfo = @"移动失败，已将好友移动到默认分组";
                NSString *errInfo = [NSString stringWithFormat:@"%@(%@)", IMALocalizedError(code, msg) ,failInfo];
                [[HUDHelper sharedInstance] tipMessage:errInfo];
                
                if (fail)
                {
                    fail(code, msg);
                }
            }];
            
        } fail:^(int code, NSString *msg) {
            DebugLog(@"Fail: %d->%@", code, msg);
            [[HUDHelper sharedInstance] tipMessage:IMALocalizedError(code, msg)];
            
            if (fail)
            {
                fail(code, msg);
            }
        }];
    }
    else if (!sub.isDefaultSubGroup && sg.isDefaultSubGroup)
    {
        [[TIMFriendshipManager sharedInstance] DelFriendsFromFriendGroup:sub.name users:@[user.userId] succ:^(NSArray *friends) {
            [[IMAPlatform sharedInstance].contactMgr onMove:user from:sub to:sg];
            if (succ)
            {
                succ(friends);
            }
        } fail:^(int code, NSString *err) {
            DebugLog(@"Fail: %d->%@", code, err);
            [[HUDHelper sharedInstance] tipMessage:IMALocalizedError(code, err)];
            
            if (fail)
            {
                fail(code, err);
            }
        }];
    }
    else
    {
        // 都是我的好友分组中
        // 不作处理
    }
}


- (void)asyncMoveToBlackList:(IMAUser *)user succ:(TIMFriendSucc)succ fail:(TIMFail)fail
{
    if (!user)
    {
        DebugLog(@"参数有误");
        return;
    }
    __weak IMAContactManager *ws = self;
    [[TIMFriendshipManager sharedInstance] AddBlackList:@[user.userId] succ:^(NSArray *friends) {
        // 从好友分组中移除
        [ws removeUserToBlackList:user];
        if (succ)
        {
            succ(friends);
        }
        
    } fail:^(int code, NSString *err) {
        DebugLog(@"Fail: %d->%@", code, err);
        if (fail)
        {
            fail(code, err);
        }
    }];

}

- (void)asyncMoveOutBlackList:(IMAUser *)user succ:(TIMFriendSucc)succ fail:(TIMFail)fail
{
    if (!user)
    {
        DebugLog(@"参数有误");
        return;
    }
    __weak IMAContactManager *ws = self;
    [[TIMFriendshipManager sharedInstance] DelBlackList:@[user.userId] succ:^(NSArray *friends) {
        // 从好友分组中移除
        [ws removeUserOutBlackList:user];
        if (succ)
        {
            succ(friends);
        }
        
    } fail:^(int code, NSString *err) {
        DebugLog(@"Fail: %d->%@", code, err);
        [[HUDHelper sharedInstance] tipMessage:IMALocalizedError(code, err)];
        
        if (fail)
        {
            fail(code, err);
        }
    }];
    

}

@end
