//
//  TIMCallView.h
//  TIMChat
//
//  Created by AlexiChen on 16/6/6.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface TIMCallView : UIImageView
{
@protected
    IMAUser                 *_callReceiver;
    BOOL                    _isCallSponsor;
    BOOL                    _isVoice;
}

/** 记录头像的坐标 */
@property (nonatomic, assign) CGPoint firstCenter;

@property (nonatomic, readonly) TCAVLivePreview *preView;

- (instancetype)initWithReceiver:(IMAUser *)user type:(BOOL)isVoice sponsor:(BOOL)isSponsor;

- (void)panPhoneView:(UIPanGestureRecognizer *)pan;
- (void)tapPhoneView:(UITapGestureRecognizer *)tap;

@end
