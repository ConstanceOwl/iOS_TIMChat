//
//  IMAAppDelegate.m
//  TIMChat
//
//  Created by AlexiChen on 16/2/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAAppDelegate.h"

#import "IMALoginViewController.h"

@implementation IMAAppDelegate

void uncaughtExceptionHandler(NSException*exception){
    DebugLog(@"CRASH: %@", exception);
    DebugLog(@"Stack Trace: %@",[exception callStackSymbols]);
}

- (void)configAppLaunch
{
    [super configAppLaunch];
    [[IMAPlatform sharedInstance] configOnAppLaunch];
}



- (void)applicationDidEnterBackground:(UIApplication *)application
{
    __block UIBackgroundTaskIdentifier bgTaskID;
    bgTaskID = [application beginBackgroundTaskWithExpirationHandler:^ {
        
        //不管有没有完成，结束background_task任务
        [application endBackgroundTask: bgTaskID];
        bgTaskID = UIBackgroundTaskInvalid;
    }];
    
    [[IMAPlatform sharedInstance] configOnAppEnterBackground];
    

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[IMAPlatform sharedInstance] configOnAppEnterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[IMAPlatform sharedInstance] configOnAppDidBecomeActive];
}


-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[IMAPlatform sharedInstance] configOnAppRegistAPNSWithDeviceToken:deviceToken];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    DebugLog(@"didFailToRegisterForRemoteNotificationsWithError:%@", error.localizedDescription);
}

//=============================================
// 收到APNS消息通知

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // 处理推送消息
    DebugLog(@"userinfo:%@", userInfo);
    DebugLog(@"收到推送消息:%@", [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    DebugLog(@"userinfo:%@", userInfo);
    DebugLog(@"收到推送消息:%@", [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    DebugLog(@"userinfo:%@", launchOptions);
    DebugLog(@"收到推送消息:%@",[[launchOptions objectForKey:@"aps"] objectForKey:@"alert"]);
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// 进入登录界面
// 用户可重写
- (void)enterLoginUI
{
    IMALoginViewController *vc = [[IMALoginViewController alloc] init];
    self.window.rootViewController = vc;
    
}


//==================================
// URL Scheme处理
- (BOOL)application:(UIApplication*)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.scheme compare:QQ_OPEN_SCHEMA] == NSOrderedSame)
    {
        return [TencentOAuth HandleOpenURL:url];
    }
    else if([url.scheme compare:WX_APP_ID] == NSOrderedSame)
    {
        if ([self.window.rootViewController conformsToProtocol:@protocol(WXApiDelegate)])
        {
            id<WXApiDelegate> lgv = (id<WXApiDelegate>)self.window.rootViewController;
            [WXApi handleOpenURL:url delegate:lgv];
            
        }
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([url.scheme compare:QQ_OPEN_SCHEMA] == NSOrderedSame)
    {
        return [TencentOAuth HandleOpenURL:url];
    }
    else if([url.scheme compare:WX_APP_ID] == NSOrderedSame)
    {
        if ([self.window.rootViewController conformsToProtocol:@protocol(WXApiDelegate)])
        {
            id<WXApiDelegate> lgv = (id<WXApiDelegate>)self.window.rootViewController;
            [WXApi handleOpenURL:url delegate:lgv];
        }
    }
    
    return YES;
}
#if kSupportCallScene
//============================================

- (TCAVCallViewController *)presentCallViewControllerWith:(IMAUser *)user type:(BOOL)isVoice callMsgHandler:(id<AVIMCallHandlerAble>)callHandler
{
//    if ([user isC2CType] || [user isGroupType])
//    {
//        IMAHost *host = [IMAPlatform sharedInstance].host;
//        IMACallRoom *callRoom = [[IMACallRoom alloc] init];
//        callRoom.callSponsor = host;
//        callRoom.callRoomID = [host getAVCallRoomID];
//        
//        TCAVCallViewController *callVC = [[TCAVCallViewController alloc] initWith:callRoom user:host];
//        callVC.enableIM = NO;
//        [self.topViewController presentViewController:callVC animated:YES completion:nil];
//        return callVC;
//    }
    return nil;
}

- (TCAVCallViewController *)presentCommingCallViewControllerWith:(AVIMCMD *)callUser conversation:(IMAConversation *)conv isFromChatting:(BOOL)isChatting
{
//    // 目前只支持好友
//    IMAUser *user = [[IMAPlatform sharedInstance].contactMgr getUserByUserId:[callUser.sender imUserId]];
//    
//    IMAHost *host = [IMAPlatform sharedInstance].host;
//    // 没有获取到，去查陌生人
////    BOOL isVoice = [callUser isVoiceCall];
//    TCAVCallViewController *callVC = [[TCAVCallViewController alloc] initWith:callUser user:host];
//    callVC.enableIM = NO;
//    
//    [self.topViewController presentViewController:callVC animated:YES completion:nil];
//    return callVC;
    
    return nil;
    
}
#endif

@end
