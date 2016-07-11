//
//  TIMCallTransition.h
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#define kTIMCallViewTag                                100000
#define kTIMCallWidth                                  240
#define kTIMCallScale                                  (568.0/[UIScreen mainScreen].bounds.size.height)

#import <Foundation/Foundation.h>



@interface TIMCallTransition : NSObject <UIViewControllerAnimatedTransitioning>


@property (nonatomic, assign) TIMTransitionType transitionType;

@property (nonatomic, assign) TIMCallPressentType pressentType;

@property (nonatomic, assign) CGRect endRect;

@property (nonatomic, assign) CGPoint lastPoint;

@property (nonatomic, assign) CGPoint controlPoint;


+ (instancetype)transitionWithQSTransitionType:(TIMTransitionType)transitionType presentType:(TIMCallPressentType)presentType;

@end
