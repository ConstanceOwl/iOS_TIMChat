//
//  IMAUser+TCAVAble.m
//  TIMChat
//
//  Created by AlexiChen on 16/6/3.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAUser+TCAVAble.h"

@implementation IMAUser (AVMultiUserAble)

- (instancetype)initWithIMUserAble:(id<IMUserAble>)imuser
{
    if (self = [super init])
    {
        self.userId = [imuser imUserId];
        self.nickName = [imuser imUserName];
        self.remark = [imuser imUserName];
        self.icon = [imuser imUserIconUrl];
    }
    return self;
}

// 用户IMSDK的identigier
- (NSString *)imUserId
{
    return [self userId];
}

// 用户昵称
- (NSString *)imUserName
{
    return [self showTitle];
}

// 用户头像地址
- (NSString *)imUserIconUrl
{
    return [self icon];
}


static NSString *const kIMAUserAVCtrlState = @"kIMAUserAVCtrlState";

- (NSInteger)avCtrlState
{
    NSNumber *num = objc_getAssociatedObject(self, (__bridge const void *)kIMAUserAVCtrlState);
    return [num integerValue];
}

- (void)setAvCtrlState:(NSInteger)avCtrlState
{
    objc_setAssociatedObject(self, (__bridge const void *)kIMAUserAVCtrlState, @(avCtrlState), OBJC_ASSOCIATION_RETAIN);
    DebugLog(@"Host [%p] Ctrl State : %d", self, (int)avCtrlState);
}

- (BOOL)isCurrentLiveHost:(id<AVRoomAble>)room
{
    return [[self imUserId] isEqualToString:[[room liveHost] imUserId]];
}


static NSString *const kIMAUserAVMultiUserState = @"kIMAUserAVMultiUserState";

static NSString *const kIMAUserAVInteractArea = @"kIMAUserAVInteractArea";
static NSString *const kIMAUserAVInvisibleInteractView = @"kIMAUserAVInvisibleInteractView";

- (NSInteger)avMultiUserState
{
    NSNumber *num = objc_getAssociatedObject(self, (__bridge const void *)kIMAUserAVMultiUserState);
    return [num integerValue];
}

- (void)setAvMultiUserState:(NSInteger)avMultiUserState
{
    objc_setAssociatedObject(self, (__bridge const void *)kIMAUserAVMultiUserState, @(avMultiUserState), OBJC_ASSOCIATION_RETAIN);
}

- (CGRect)avInteractArea
{
    NSValue *num = objc_getAssociatedObject(self, (__bridge const void *)kIMAUserAVInteractArea);
    return [num CGRectValue];
}

- (void)setAvInteractArea:(CGRect)avInteractArea
{
    objc_setAssociatedObject(self, (__bridge const void *)kIMAUserAVInteractArea, [NSValue valueWithCGRect:avInteractArea], OBJC_ASSOCIATION_RETAIN);
}


- (UIView *)avInvisibleInteractView
{
    return  objc_getAssociatedObject(self, (__bridge const void *)kIMAUserAVInvisibleInteractView);
}

- (void)setAvInvisibleInteractView:(UIView *)avInvisibleInteractView
{
    objc_setAssociatedObject(self, (__bridge const void *)kIMAUserAVInvisibleInteractView, avInvisibleInteractView, OBJC_ASSOCIATION_ASSIGN);
}

@end

//============================================================
// 此处群不是IMUserAble对象，因其继承了IMAUser，所以加下处理
@interface IMAGroup (TCAVAble)

@end

@implementation IMAGroup (TCAVAble)

// 用户IMSDK的identigier
- (NSString *)imUserId
{
    return [self userId];
}

// 用户昵称
- (NSString *)imUserName
{
    return [self showTitle];
}

// 用户头像地址
- (NSString *)imUserIconUrl
{
    return [self icon];
}



- (NSInteger)avCtrlState
{
    return 0;
}

- (void)setAvCtrlState:(NSInteger)avCtrlState
{
}

- (BOOL)isCurrentLiveHost:(id<AVRoomAble>)room
{
    return NO;
}

- (NSInteger)avMultiUserState
{
    return 0;
}

- (void)setAvMultiUserState:(NSInteger)avMultiUserState
{
    
}

- (CGRect)avInteractArea
{
    return CGRectZero;
}

- (void)setAvInteractArea:(CGRect)avInteractArea
{
}


- (UIView *)avInvisibleInteractView
{
    return nil;
}

- (void)setAvInvisibleInteractView:(UIView *)avInvisibleInteractView
{
    
}


@end

//============================================================

