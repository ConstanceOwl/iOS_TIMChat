//
//  TIMCallHeader.h
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#ifndef TIMCallHeader_h
#define TIMCallHeader_h

typedef NS_ENUM(NSInteger,TIMCallPressentType) {
    
    TIMCallTransitionPressentTypeNormal = 0,
    TIMCallTransitionPressentTypeMask = 1,
};

typedef NS_ENUM(NSInteger, TIMTransitionType)
{
    TIMTransitionTypePresent = 0,
    TIMTransitionTypeDismiss  = 1
};

#define kTCShowMultiSubViewSize CGSizeMake(80, 120)

#import "TIMChatCallRoomEngine.h"

#import "TIMCallTopView.h"

#import "TIMCallView.h"

#import "TCShowMultiSubView.h"

#import "TCShowMultiView.h"


#import "TIMCallBeautyView.h"

#import "TIMCallViewController.h"

#import "TIMCallTransition.h"

#endif /* TIMCallHeader_h */
