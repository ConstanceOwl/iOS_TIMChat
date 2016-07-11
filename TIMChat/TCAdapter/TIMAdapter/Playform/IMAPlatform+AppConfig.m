//
//  IMAPlatform+AppConfig.m
//  TIMChat
//
//  Created by AlexiChen on 16/2/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAPlatform+AppConfig.h"

@implementation IMAPlatform (AppConfig)


// app 启动时配置
- (void)configOnAppLaunch
{
    // TODO:大部份在IMAPlatform创建的时候处理了，此处添加额外处理，用户自行添加
    
}

// app 进入后台时配置
- (void)configOnAppEnterBackground
{
    
    // 将相关的配置缓存至本地
    [[IMAPlatform sharedInstance] saveToLocal];
    
    
    NSUInteger unReadCount = [[IMAPlatform sharedInstance].conversationMgr unReadMessageCount];
    [UIApplication sharedApplication].applicationIconBadgeNumber = unReadCount;
    
    TIMBackgroundParam *param = [[TIMBackgroundParam alloc] init];
    [param setC2cUnread:(int)unReadCount];
    
    
    [[TIMManager sharedInstance] doBackground:param succ:^() {
        DebugLog(@"doBackgroud Succ");
    } fail:^(int code, NSString * err) {
        DebugLog(@"Fail: %d->%@", code, err);
    }];
}

// app 进前台时配置
- (void)configOnAppEnterForeground
{
    [UIApplication.sharedApplication.windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *w, NSUInteger idx, BOOL *stop) {
        if (!w.opaque && [NSStringFromClass(w.class) hasPrefix:@"UIText"]) {
            // The keyboard sometimes disables interaction. This brings it back to normal.
            BOOL wasHidden = w.hidden;
            w.hidden = YES;
            w.hidden = wasHidden;
            *stop = YES;
        }
    }];
}

// app become active
- (void)configOnAppDidBecomeActive
{
    [[TIMManager sharedInstance] doForeground];
}

// app 注册APNS成功后
- (void)configOnAppRegistAPNSWithDeviceToken:(NSData *)deviceToken
{
    DebugLog(@"didRegisterForRemoteNotificationsWithDeviceToken:%ld", (unsigned long)deviceToken.length);
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    [[TIMManager sharedInstance] log:TIM_LOG_INFO tag:@"SetToken" msg:[NSString stringWithFormat:@"My Token is :%@", token]];
    TIMTokenParam *param = [[TIMTokenParam alloc] init];
    

#if DEBUG
    param.busiId = 1;
#else
    param.busiId = 2;
#endif

    
    [param setToken:deviceToken];
    
    [[TIMManager sharedInstance] setToken:param];
}




@end
