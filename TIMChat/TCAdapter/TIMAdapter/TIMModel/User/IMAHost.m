//
//  IMAHost.m
//  TIMAdapter
//
//  Created by AlexiChen on 16/1/29.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAHost.h"

@implementation IMAHost

- (void)asyncProfile
{
    __weak IMAHost *ws = self;
    [[TIMFriendshipManager sharedInstance] GetSelfProfile:^(TIMUserProfile *selfProfile) {
        DebugLog(@"Get Self Profile Succ");
        ws.profile = selfProfile;
    } fail:^(int code, NSString *err) {
        DebugLog(@"Get Self Profile Failed: code=%d err=%@", code, err);
        [[HUDHelper sharedInstance] tipMessage:IMALocalizedError(code, err)];
    }];
}

- (BOOL)isMe:(IMAUser *)user
{
    return [self.userId isEqualToString:user.userId];
}


- (void)setLoginParm:(TIMLoginParam *)loginParm
{
    _loginParm = loginParm;
    [_loginParm saveToLocal];
}

- (BOOL)isEqual:(id)object
{
    BOOL isEqual = [super isEqual:object];
    if (!isEqual)
    {
        if ([object conformsToProtocol:@protocol(IMUserAble)])
        {
            id<IMUserAble> io = (id<IMUserAble>)object;
            isEqual = [[self imUserId] isEqualToString:[io imUserId]];
        }
    }
    return isEqual;
}


- (NSString *)userId
{
    return _profile ? _profile.identifier : _loginParm.identifier;
}
- (NSString *)icon
{
    return nil;
}
- (NSString *)remark
{
    return ![NSString isEmpty:_profile.nickname] ? _profile.nickname : _profile.identifier;
}
- (NSString *)name
{
    return ![NSString isEmpty:_profile.nickname] ? _profile.nickname : _profile.identifier;
}
- (NSString *)nickName
{
    return ![NSString isEmpty:_profile.nickname] ? _profile.nickname : _profile.identifier;
}

// 当前App对应的AppID
- (NSString *)imSDKAppId
{
    return kSdkAppId;
}

// 当前App的AccountType
- (NSString *)imSDKAccountType
{
    return kSdkAccountType;
}

- (int)getAVCallRoomID
{
    return [_loginParm avCallRoomID];
}


@end
