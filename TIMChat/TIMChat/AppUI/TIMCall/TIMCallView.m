//
//  TIMCallView.m
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "TIMCallView.h"
#import "TIMCallViewController.h"

@implementation TIMCallView

- (void)dealloc
{
    DebugLog(@"TIMCallView Release");
    [_preView stopPreview];
}

- (instancetype)initWithReceiver:(IMAUser *)user type:(BOOL)isVoice sponsor:(BOOL)isSponsor
{
    if (self = [self init])
    {
        _callReceiver = user;
        _isVoice = isVoice;
        _isCallSponsor = isSponsor;
    }
    return self;
}

- (void)tapPhoneView:(UITapGestureRecognizer *)tap
{
    TIMCallViewController *onlineVC = (TIMCallViewController *)[IMAPlatform sharedInstance].callViewController;
    onlineVC.pressentType = TIMCallTransitionPressentTypeMask;
    
    CommonVoidBlock block = ^{
        onlineVC.callFloatView = nil;
        [onlineVC.livePreview startPreview];
    };
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    id vc = window.rootViewController;
    
    if ([vc isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nav = (UINavigationController *)vc;
        [nav.topViewController presentViewController:onlineVC animated:YES completion:block];
    }
    else if ([vc isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tab = (UITabBarController *)vc;
        [tab presentViewController:onlineVC animated:YES completion:block];
    }
    else if ([vc isKindOfClass:[UIViewController class]])
    {
        [vc presentViewController:onlineVC animated:YES completion:block];
    }
}

- (void)panPhoneView:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:[UIApplication sharedApplication].keyWindow];
    TIMCallView *view = (TIMCallView *)pan.view;
    
    CGFloat distance = 40;  // 离四周的最小边距
    
    if (pan.state == UIGestureRecognizerStateEnded)
    {
        if (point.y <= distance)
        {
            point.y = distance;
        }
        else if (point.y >= [UIScreen mainScreen].bounds.size.height - distance)
        {
            point.y = [UIScreen mainScreen].bounds.size.height - distance;
        }
        else if (point.x <= [UIScreen mainScreen].bounds.size.width/2.0)
        {
            point.x = distance;
        }
        else
        {
            point.x = [UIScreen mainScreen].bounds.size.width - distance;
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            view.center = point;
        }];
        
    }
    else
    {
        view.center = point;
    }
    
}

@end
