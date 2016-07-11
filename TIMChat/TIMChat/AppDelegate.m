//
//  AppDelegate.m
//  TIMChat
//
//  Created by AlexiChen on 16/1/29.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "AppDelegate.h"

#import <TencentOpenAPI/TencentOAuth.h>

#import "WXApi.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


- (void)configAppLaunch
{
    //    // 作App配置
    //    [super configAppLaunch];
    //
    //
    //    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    //    [[UINavigationBar appearance] setBarTintColor:RGBA(0x0, 0xEE, 0xEE, 0)];
    //    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //
    //    UIColor *highlightColor = RGBA(0x12, 0xa8, 0x6b, 1.0f);
    //    UIColor *normalColor = [UIColor colorWithWhite:0.3f alpha:1.f];
    //
    //    NSDictionary *selectedTextAttr = @{NSForegroundColorAttributeName: highlightColor, NSFontAttributeName: [UIFont systemFontOfSize:10.f]};;
    //    NSDictionary *normalTextAttr = @{NSForegroundColorAttributeName: normalColor, NSFontAttributeName: [UIFont systemFontOfSize:10.f]};;
    //
    //    [[UITabBarItem appearance] setTitleTextAttributes:selectedTextAttr forState:UIControlStateSelected];
    //    [[UITabBarItem appearance] setTitleTextAttributes:normalTextAttr forState:UIControlStateNormal];
    
    [[NSClassFromString(@"UICalloutBarButton") appearance] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}




- (void)enterMainUI
{
    self.window.rootViewController = [[TIMTabBarController alloc] init];
}

+ (instancetype)sharedAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}


- (void)pushToChatViewControllerWith:(IMAUser *)user
{
    
    TIMTabBarController *tab = (TIMTabBarController *)self.window.rootViewController;
    [tab pushToChatViewControllerWith:user];
}


#if kSupportCallScene
- (TCAVCallViewController *)presentCallViewControllerWith:(IMAUser *)user type:(BOOL)isVoice callMsgHandler:(id<AVIMCallHandlerAble>)callHandler
{
    if ([user isC2CType] || [user isGroupType])
    {
        IMAHost *host = [IMAPlatform sharedInstance].host;
        IMACallRoom *callRoom = [[IMACallRoom alloc] init];
        callRoom.callSponsor = host;
        callRoom.callRoomID = [host getAVCallRoomID];
        if ([user isGroupType])
        {
            callRoom.callGroupID = [user imUserId];
            callRoom.callGroupType = [(IMAGroup *)user groupType];
        }
        
        TIMCallViewController *callVC = [[TIMCallViewController alloc] initWith:callRoom user:host];
        callVC.callMsgHandler = callHandler;
        callVC.isVoice = isVoice;
        callVC.isCallSponsor = YES;
        callVC.callReceiver = user;
        callVC.enableIM = NO;
        
        if ([[UIApplication sharedApplication].keyWindow viewWithTag:kTIMCallViewTag])
        {
            callVC.pressentType = TIMCallTransitionPressentTypeMask;
        }
        else
        {
            callVC.pressentType = TIMCallTransitionPressentTypeNormal;
        }
        
        [self.topViewController presentViewController:callVC animated:YES completion:nil];
        [IMAPlatform sharedInstance].callViewController = callVC;
        return callVC;
    }
    return nil;
}

- (TCAVCallViewController *)presentCommingCallViewControllerWith:(AVIMCMD *)callUser conversation:(IMAConversation *)conv isFromChatting:(BOOL)isChatting
{
    // 目前只支持好友
    IMAUser *user = nil;
    if (callUser.isGroupCall)
    {
        user = [[IMAPlatform sharedInstance].contactMgr getUserByGroupId:[callUser liveIMChatRoomId]];
        if (!user)
        {
            TIMGroupInfo *gi = [[TIMGroupInfo alloc] init];
            gi.group = [callUser liveIMChatRoomId];
            gi.groupName = [callUser liveIMChatRoomId];
            gi.groupType = [callUser callGroupType];
            user = [[IMAGroup alloc] initWithInfo:gi];
        }
    }
    else
    {
        
        user = [[IMAPlatform sharedInstance].contactMgr getUserByUserId:[callUser.sender imUserId]];
    }
    
    
    IMAHost *host = [IMAPlatform sharedInstance].host;
    // 没有获取到，去查陌生人
    BOOL isVoice = [callUser isVoiceCall];
    TIMCallViewController *callVC = [[TIMCallViewController alloc] initWith:callUser user:host];

    if (isChatting)
    {
        TIMTabBarController *tab = (TIMTabBarController *)self.window.rootViewController;
        callVC.callMsgHandler = [tab chatViewController];
    }
    
    if (!callVC.callMsgHandler)
    {
        callVC.callMsgHandler = conv;
    }
    callVC.isCallSponsor = NO;
    callVC.isVoice = isVoice;
    callVC.callReceiver = user;
    callVC.enableIM = NO;
    callVC.isInviteCall = [callUser msgType] == AVIMCMD_Call_Invite;
    
    if ([[UIApplication sharedApplication].keyWindow viewWithTag:kTIMCallViewTag])
    {
        callVC.pressentType = TIMCallTransitionPressentTypeMask;
    }
    else
    {
        callVC.pressentType = TIMCallTransitionPressentTypeNormal;
    }
    
    [self.topViewController presentViewController:callVC animated:YES completion:nil];
    return callVC;
}
#endif
@end
